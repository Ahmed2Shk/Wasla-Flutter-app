import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wasla_app/core/widgets/otp_input_field.dart';

/// تست ضد رجوع نفس الباگ يلي انصلح: صناديق الـ OTP كانت تترتب من اليمين
/// لليسار (وريث اتجاه التطبيق العام RTL)، فصار التركيز يتحرك "للخلف" بصرياً
/// والرمز يبين مقلوب. هون بنغلّف التطبيق بنفس RTL يلي بالتطبيق الحقيقي
/// (main.dart) عمداً، ونتأكد إنه صناديق الأرقام نفسها ضلّت LTR رغم هيك.
void main() {
  Future<void> pumpBoxes(WidgetTester tester, {required int length}) async {
    await tester.pumpWidget(
      MaterialApp(
        // نفس اللف يلي main.dart بيعمله على مستوى التطبيق كامل
        builder: (context, child) => Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        ),
        home: Scaffold(
          body: SegmentedCodeInput(length: length, onCompleted: (_) {}),
        ),
      ),
    );
  }

  testWidgets('صناديق الأرقام تترتب من اليسار لليمين حتى جوا تطبيق RTL', (tester) async {
    await pumpBoxes(tester, length: 6);

    final boxes = find.byType(TextField);
    expect(boxes, findsNWidgets(6));

    // كل صندوق لازم يكون على يمين (dx أكبر) يلي قبله — يعني ترتيب بصري
    // من اليسار لليمين بالضبط متل أي رمز OTP عادي، بغض النظر عن اتجاه التطبيق
    double? previousDx;
    for (var i = 0; i < 6; i++) {
      final dx = tester.getTopLeft(boxes.at(i)).dx;
      if (previousDx != null) {
        expect(dx, greaterThan(previousDx), reason: 'الصندوق $i لازم يكون يمين الصندوق ${i - 1}');
      }
      previousDx = dx;
    }
  });

  testWidgets('كتابة الأرقام بالترتيب بتطلع الرمز الصحيح (مش مقلوب)', (tester) async {
    String? completedCode;
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        ),
        home: Scaffold(
          body: SegmentedCodeInput(length: 4, onCompleted: (c) => completedCode = c),
        ),
      ),
    );

    final boxes = find.byType(TextField);
    const digits = ['1', '2', '3', '4'];
    for (var i = 0; i < 4; i++) {
      await tester.enterText(boxes.at(i), digits[i]);
      await tester.pump();
    }

    expect(completedCode, '1234');
  });

  testWidgets('كتابة رقم بالصندوق الأول تنقل التركيز للصندوق التالي', (tester) async {
    await pumpBoxes(tester, length: 4);

    final boxes = find.byType(TextField);
    await tester.enterText(boxes.at(0), '5');
    await tester.pump();

    final secondField = tester.widget<TextField>(boxes.at(1));
    expect(secondField.focusNode?.hasFocus, isTrue);
  });
}
