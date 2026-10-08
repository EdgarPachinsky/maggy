/// How well Magic supports a given application.
enum CompatibilityStatus {
  supported('Supported'),
  supportedWithLimitations('Supported with limitations'),
  experimental('Experimental'),
  unsupported('Unsupported'),
  unknown('Unknown');

  const CompatibilityStatus(this.label);
  final String label;
}
