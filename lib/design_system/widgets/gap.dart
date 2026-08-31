import 'package:flutter/material.dart';

/// Semantic UI spacing widget wrapping [SizedBox].
class Gap extends StatelessWidget {
  const Gap(this.size, {super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: size, height: size);
  }
}

/// 2px spacing widget (ajuste ótico).
class Gap2 extends Gap {
  const Gap2({super.key}) : super(2.0);
}

/// 4px spacing widget (gap dentro de tag).
class Gap4 extends Gap {
  const Gap4({super.key}) : super(4.0);
}

/// 8px spacing widget (gap em botão e input).
class Gap8 extends Gap {
  const Gap8({super.key}) : super(8.0);
}

/// 12px spacing widget.
class Gap12 extends Gap {
  const Gap12({super.key}) : super(12.0);
}

/// 16px spacing widget (padding/gap padrão).
class Gap16 extends Gap {
  const Gap16({super.key}) : super(16.0);
}

/// 24px spacing widget.
class Gap24 extends Gap {
  const Gap24({super.key}) : super(24.0);
}

/// 32px spacing widget (entre blocos).
class Gap32 extends Gap {
  const Gap32({super.key}) : super(32.0);
}

/// 40px spacing widget.
class Gap40 extends Gap {
  const Gap40({super.key}) : super(40.0);
}

/// 48px spacing widget.
class Gap48 extends Gap {
  const Gap48({super.key}) : super(48.0);
}

/// 64px spacing widget (entre seções).
class Gap64 extends Gap {
  const Gap64({super.key}) : super(64.0);
}
