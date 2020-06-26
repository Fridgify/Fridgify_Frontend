enum Permissions {
  user,
  overseer,
  owner,
}

extension PermissionsExtension on Permissions {
  Permissions byName(String name) {
    switch (name.toLowerCase()) {
      case 'fridge user':
        return Permissions.user;
      case 'fridge overseer':
        return Permissions.overseer;
      case 'fridge owner':
        return Permissions.owner;
      default:
        return null;
    }
  }

  String value() {
    switch (this) {
      case Permissions.user:
        return 'Fridge User';
      case Permissions.overseer:
        return 'Fridge Overseer';
      case Permissions.owner:
        return 'Fridge Owner';
      default:
        return null;
    }
  }

}
