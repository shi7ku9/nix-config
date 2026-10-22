# Hermetic test derivation for appimage-sync (see _test.sh). Takes the package
# as an argument so a modified script can be tested the same way.
{
  runCommand,
  appimage-sync,
  desktop-file-utils,
  glib,
}:

runCommand "appimage-sync-test"
  {
    nativeBuildInputs = [
      desktop-file-utils # desktop-file-validate
      glib.bin # gio launch
    ];
  }
  ''
    APPIMAGE_SYNC=${appimage-sync}/bin/appimage-sync bash ${./_test.sh}
    touch $out
  ''
