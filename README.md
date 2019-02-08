# Advanced Treble ROM Build Script

# Info:
* This script is a custom version of ``build-dakkar`` from ``https://github.com/phhusson/treble_experimentations`` , With lot of optimizations, changes and adds.
- **Current Version:** V0.1 (BETA)
- **Current Stable Version:** N/A
- **Current Features:**
   * Automaticly Init Repo And Sync
      - Withn Only Current Branch.
      - Without Tags/Bundles Cloning.
      - Faster And Stable.
   * Fully Support Of MTK
      - With Latest Patches, USSD,Incoming Calls Works (Both Pie/Oreo)
   * Removed All Spefict Qcom Devices Overlays/Changes.
   * Lot Of ROMs Available To Build )

# Usage Info:
- Make A Folder (Sperated location from where this is cloned) Of The Target ROM.
  lets say: ``/home/username/aex`` , And ``/home/username/adv-script/`` is where Adv Cloned.
- Navigate To ``aex``, And Run:
 ``bash ../adv*.sh aex81 arm-aonly-vanilla-nosu-user``
  * This is for making a rom for a ``arm-aonly`` device without ``gapps`` and ``su``.
  Run ``bash adv-build.sh`` for commend syntax guide.

# Credits:
- phhusson
- EnesSastim
