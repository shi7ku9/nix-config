# Hermetic test derivation for appimage-unbundle (see _unbundle-test.sh).
# Takes the package as an argument so a modified script can be tested the
# same way.
{
  runCommand,
  appimage-unbundle,
  squashfsTools,
}:

runCommand "appimage-unbundle-test"
  {
    nativeBuildInputs = [
      squashfsTools # build and inspect the fake images
    ];
  }
  ''
    APPIMAGE_UNBUNDLE=${appimage-unbundle}/bin/appimage-unbundle bash ${./_unbundle-test.sh}
    touch $out
  ''
