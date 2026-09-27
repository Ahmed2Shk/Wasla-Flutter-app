/// تطبيق مبسّط لـ Either بدون الحاجة لمكتبة dartz
/// Left = فشل (Failure) | Right = نجاح (Success)
sealed class Either<L, R> {
  const Either();

  T fold<T>(T Function(L l) onLeft, T Function(R r) onRight) {
    final self = this;
    if (self is Left<L, R>) return onLeft(self.value);
    if (self is Right<L, R>) return onRight(self.value);
    throw StateError('Unreachable');
  }

  bool get isLeft => this is Left<L, R>;
  bool get isRight => this is Right<L, R>;
}

class Left<L, R> extends Either<L, R> {
  final L value;
  const Left(this.value);
}

class Right<L, R> extends Either<L, R> {
  final R value;
  const Right(this.value);
}
