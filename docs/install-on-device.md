# Put the app on an iPhone

Without a paid developer membership, the app is signed with the **Personal
Team** of a free Apple Account and installed from the Mac with Xcode. That is
how it reaches the student's iPhone until iteration 007 brings TestFlight.

Before you start, follow the README's
[Development setup](../README.md#development-setup), steps 1 to 5. Most of
what follows is done once; [renewing after seven days](#5-every-seven-days-renew)
is the part that repeats.

## 1. Sign with your Personal Team

Once per Mac.

1. In Xcode, open *Settings → Accounts → +* and choose **Apple Account**, then
   sign in. The account shows a team named after you, marked
   **Personal Team**.
2. Find the team's ID: ten letters and digits.

   ```bash
   defaults export com.apple.dt.Xcode - \
     | plutil -extract IDEProvisioningTeamByIdentifier json -o - - \
     | jq -r '.[][] | "\(.teamID)  \(.teamType)  \(.teamName)"'
   ```

   The ID is in front of `Personal Team`.
3. Put it into the local signing file, which git ignores:

   ```bash
   cp Config/Signing.local.xcconfig.example Config/Signing.local.xcconfig
   ```

   Open `Config/Signing.local.xcconfig`, and replace the example ID after
   `DEVELOPMENT_TEAM =` with yours.
4. Check that the build sees it. This prints your ID:

   ```bash
   xcodebuild -showBuildSettings -project Schulplaner.xcodeproj -scheme Schulplaner \
     | grep ' DEVELOPMENT_TEAM ='
   ```

Do not choose the team in Xcode's *Signing & Capabilities* tab. Xcode would
write it into the project file, the repository is public, and CI fails on it
(`scripts/check-signing.sh`). If it has happened, set the team there back to
**None**.

## 2. Connect the iPhone

Once per iPhone and Mac.

1. Connect the iPhone with a cable and unlock it. To **Trust This
   Computer?**, answer **Trust**, and enter the iPhone's passcode.
2. In Xcode, open *Window → Devices and Simulators*. The iPhone appears under
   *Devices*. The first time, Xcode prepares it for development. That takes a
   few minutes, and Xcode shows its progress there.
3. Optional, so that renewing needs no cable later: tick **Connect via
   network**. From then on, the Mac finds the iPhone whenever both are on the
   same Wi-Fi.

## 3. Turn on Developer Mode

Once per iPhone. The setting appears only after the iPhone has been connected
to Xcode once.

1. On the iPhone, open *Settings → Privacy & Security → Developer Mode*. It is
   near the bottom of the list. Turn it on.
2. The iPhone asks to restart: **Restart**.
3. After the restart, it asks once more: **Turn On**, and enter the passcode.

## 4. Install from Xcode

1. Open `Schulplaner.xcodeproj`. In the toolbar, choose the scheme
   **Schulplaner** and, as run destination, the iPhone.
2. Run with **⌘R**. The first time, Xcode registers the app with your
   Personal Team and makes a provisioning profile. The app is installed, but
   iOS does not open it yet, because the iPhone does not trust you as a
   developer.
3. On the iPhone, open *Settings → General → VPN & Device Management*. Under
   **Developer App**, tap your Apple Account, then **Trust**, and confirm.
4. Run with **⌘R** again. The app opens.

Step 3 of this section and all of section 3 are done once per iPhone.

Without Xcode's window, one command does the same for the iPhone connected to
the Mac: it builds the app as the student uses it (Release), installs it over
the one that is there, starts it, and says until when it opens.

```bash
bash scripts/install-on-iphone.sh
```

## 5. Every seven days: renew

With a free account, the provisioning profile is valid for **seven days from
when Xcode made it**. After that, the app no longer opens. Its data is still
there.

Running the app from Xcode again does not add a day while that profile is
still valid, because Xcode reuses it. A fresh seven days need a fresh
profile, and the script makes one: it removes this app's old profile first.
So, with the iPhone connected by cable, or on the same Wi-Fi if you ticked
*Connect via network*:

```bash
bash scripts/install-on-iphone.sh
```

It ends with the day and time until which the app opens. Run it at a time
that suits the week, such as Sunday evening: then the app runs through the
school week and expires on the weekend. Once the profile has expired, ⌘R in
Xcode renews it as well.

Installing over the app keeps its data, so the student's homework stays.

**Never delete the app to fix it.** Until iCloud sync exists, deleting the app
deletes the student's data with it. Only the iPhone's own backup keeps a copy.

## What a free account cannot do

- **iCloud sync.** A Personal Team cannot use iCloud, so the data lives only
  on the iPhone and in its backup. Sync arrives with the membership, in
  iteration 007 ([ADR-0003](adr/0003-store-data-with-swiftdata-in-a-cloudkit-compatible-model.md)).
- **TestFlight and the App Store.** Both need the membership, also in 007.
  Until then, every installation goes through Xcode, as above.
- **Longer than seven days.** A membership's profiles last a year.
- **More than a few apps.** A free account can have three apps installed on
  one iPhone at a time, and can register a limited number of new apps per
  week. Schulplaner counts as one of them.

Reminders that the app schedules itself, which are local notifications, need
no membership.

## When it does not work

| Xcode or the iPhone says | Then |
| --- | --- |
| *Signing for "Schulplaner" requires a development team* | `Config/Signing.local.xcconfig` is missing or has no team: [section 1](#1-sign-with-your-personal-team). |
| *Developer Mode disabled* | [Section 3](#3-turn-on-developer-mode). |
| *Untrusted Developer*, or the app does not open after installing | [Section 4](#4-install-from-xcode), step 3. |
| The app opened for a week and now does not | The profile expired: [renew](#5-every-seven-days-renew). |
| `scripts/install-on-iphone.sh` says the app did not start | The iPhone was locked. Unlock it, and open Schulplaner by hand. |
| *Failed Registering Bundle Identifier* | `io.github.nicoschmidt.schulplaner` belongs to another team. Only one team can register a bundle identifier. |
| The iPhone is not offered as a run destination | Unlock it, and check *Window → Devices and Simulators*: it may still be preparing, or need the cable again. |
