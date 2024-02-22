# Tech Case 16: Microphone mixer

![Microphone mixer header image](/static/images/microphone-mixer.png)

## Document overview

- [Tech Case 16: Microphone mixer](#tech-case-16-microphone-mixer)
  - [Document overview](#document-overview)
  - [Canvas case](#canvas-case)
    - [Interpretation](#interpretation)
    - [Available technologies](#available-technologies)
    - [Technological overview](#technological-overview)

## Canvas case

> Create an app that can be used to make a studio recording with two microphones. You need 3 physical phones to test and show this to the teachers.

The use case is as follows:

    - Two phones serve as a microphone and can record audio.
    - The phones record audio simultaneously.
    - The audio of the two phones is mixed and recorded as
      - one audio stream OR audio file
    - The stream or file can be opened on the third phone.

### Interpretation

Terms to clarify this work-document:

- Phone A - 1 phone that is actively recording.
- Phone B - 1 phone that is actively recording.
- Phone C - 1 phone that is actively receiving.

| ${\textsf{\color{lightgreen}Must have}}$ | ${\textsf{\color{orange}Could have}}$      | ${\textsf{\color{red}Won't have}}$ |
| ---------------------------------------- | ------------------------------------------ | ---------------------------------- |
| Be able to connect 2 devices to phone C. | Add more than 2 devices to C.              | Accounts, works locally only.      |
| Share audio files/streams locally.       | Save audio streams.                        |                                    |
| Synchronously record/stream audio.       | Transfer audio files between phones in-app |                                    |
|                                          | Serverless architecture                    |                                    |

### Available technologies

In order to develop an app within 3 weeks, third-party tools such as packages or external servers would be required to use, as within the scope of the application's development creating such a service itself would be difficult ~~to say the least~~.

A list of requirements has been created:

- Audio receiving - The tool must support receiving audio (-in phone C).
- Audio sending - The tool must support sending audio (-to phone C).
- Audio file transfer - The tool must support (easily-) transferring audio files between devices.
- Participant management - Being able to add more than 2 entities and/or removing/adding entities.
- Serverless - Does not require a third-party paid nor unpaid service.

|                        | Stream™ [^1] | flutter_blue [^2] | just_audio [^3] | flutter_p2p_connection [^4] |
| ---------------------- | ------------ | ----------------- | --------------- | --------------------------- |
| Audio receiving        | ✅           | ✅                | ✅              | ✅                          |
| Audio sending          | ✅           | ✅                | ❌              | ✅                          |
| Audio file transfer    | ❌           | ✅                | ❌              | ✅                          |
| Audio mixing           | ❌           | ❌                | ❌              | ❌                          |
| Participant management | ✅           | ❌                | ❌              | ✅                          |
| Serverless             | ❌           | ✅                | ✅              | ✅                          |

According to this small-scale research it is safe to say that flutter_p2p_connection is the most well-suited package for our implementation in this project. It's well documented, has examples, matches in the most requirements and is using an already well-defined protocol.

Next to that the 1 requirement which was not met 'Audio mixing', this package forms a solution that can be applied to most of the requirements within the project. The one requirement can be solved using FFmpeg[^5] which is well supported and documented both generally speaking and specific to flutter.

---

### Technological overview

To provide a better overview over how the devices interact with one another a few diagrams have been created. The first diagram shows how the users globally interact with one another to create connections on which data can be sent. In this case this is done by creating a 'group', a group is nothing more than a collection of devices within Wifi-Direct. 1 Device ('Studio phone) creates the group and is automatically assigned ownership.

![Group management diagram](/static/images/tech-case-microphone-mixer-group-management.png)

Within a session, a phone can both send/receive. The 'studio' phone would, in this instance, only send requests to start/stop recording. The receiving would be said audio files. The recording phones are doing the opposite, receiving requests and sending audio files.

![Recording management diagram](/static/images/tech-case-microphone-mixer-recording-management.png)

![File management diagram](/static/images/tech-case-microphone-mixer-file-management.png)

[^1]: [Stream™ is a third-party service that can provide high-quality audio/video streaming using their servers.](https://getstream.io/video/docs/flutter/)
[^2]: [Flutter blue is a package for handling BLE (Bluetooth low energy) data exchange in Flutter using characteristics and descriptors.](https://pub.dev/packages/flutter_blue/example)
[^3]: [Just audio is a out-of-the-box package for implementing media-controls to audio streams/files.](https://pub.dev/packages/just_audio)
[^4]: [Flutter P2P is a package using Wifi-Direct to implement P2P connections between devices to send and receive data.](https://pub.dev/packages/flutter_p2p_connection)
[^5]: https://pub.dev/packages/ffmpeg_kit_flutter
