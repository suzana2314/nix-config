{ lib }:
{
  mkGcode =
    text:
    "\n"
    + lib.concatMapStringsSep "\n" (l: if l == "" then "" else "  " + l) (
      lib.splitString "\n" (lib.removeSuffix "\n" text)
    );
}
