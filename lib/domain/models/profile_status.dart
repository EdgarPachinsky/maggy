/// Runtime status of a Magic profile.
enum ProfileStatus {
  ready('Ready'),
  launching('Launching'),
  running('Running'),
  stopped('Stopped'),
  error('Error');

  const ProfileStatus(this.label);
  final String label;
}
