# Advanced GSI ROM Build Script

## Info:
* This script is a custom version of ``build-dakkar`` from [here](https://github.com/phhusson/treble_experimentations), With lot of optimizations, fixes, improvemets and more features.
- **Current Version:** V1.5 (STABLE)
- **Current Stable Version:** 1.5
- **Current Features:**
   * Automaticly sync, patch and build!:
      - Faster and stable syncing.
      - Patching from HEAD, always updated, no fails.
      - Prompting and take user choice for every step.
   * Fixes some common build errors, lot of roms are supported!

## Usage Info:
- Make a folder (sperated location from where this tool is cloned) of the ROM you want to collect.
  lets say: ``/home/username/aex``, and ``/home/username/adv-script/`` is where the script was cloned. 
- Navigate to ``aex``, and run:
 ``bash ../adv*.sh aex81 arm-aonly-vanilla-nosu``
  * This is for making a rom for a ``arm-aonly`` treblized device without ``gapps`` and ``su``.
- Run ``bash adv-build.sh --help`` for commend syntax guide.

## Aknowledgement:
- phhusson
- EnesSastim
- nathanchance
