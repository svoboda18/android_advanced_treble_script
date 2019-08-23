# Advanced Treble ROM Build Script

# Info:
* This script is a custom version of ``build-dakkar`` from ``https://github.com/phhusson/treble_experimentations`` , With lot of optimizations, changes and adds.
- **Current Version:** V1.0 (STABLE)
- **Current Stable Version:** 1
- **Current Features:**
   * Automaticly sync, patch and build!:
      - Faster and stable syncing.
      - Patching from HEAD, always updated, no fails.
      - Prompting and take user choice for every step.
   * Fixes some common build errors, lot of roms are supported!

# Usage Info:
- Make A Folder (Sperated location from where this is cloned) Of The Target ROM.
  lets say: ``/home/username/aex`` , And ``/home/username/adv-script/`` is where Adv Cloned.
- Navigate To ``aex``, And Run:
 ``bash ../adv*.sh aex81 arm-aonly-vanilla-nosu-user``
  * This is for making a rom for a ``arm-aonly`` device without ``gapps`` and ``su``.
- Run ``bash adv-build.sh`` for commend syntax guide.

# Credits:
- phhusson
- EnesSastim
- nathanchance
