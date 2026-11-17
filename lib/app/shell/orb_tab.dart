/// The four tabs in the bottom bar, in display order.
///
/// The order matches the branch order in `router.dart`, so a tab's [index]
/// is also its branch index.
enum OrbTab {
  home('Home', '/home'),
  space('Space', '/space'),
  quest('Quest', '/quest'),
  profile('Profile', '/profile');

  const OrbTab(this.label, this.path);

  final String label;
  final String path;

  String get activeIcon => 'assets/svg/tabs/tab_${name}_active.svg';
  String get inactiveIcon => 'assets/svg/tabs/tab_${name}_inactive.svg';
}
