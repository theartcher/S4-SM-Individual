# What the f\*\*\* is this?

This is very basic node code for creating an unsecured very minimal express API for posting and getting audio files. When getting audio files, all audio files within corresponding folder are merged together, the output is saved in said folder and then returned to the user. If the same id is called twice, the output.m4a is overwritten.

## Getting started

1. Copy/clone repository.
2. Open a terminal.
3. Open folder which code was copied/cloned to.
4. Run the command.

   ```npm
   npm i
   ```

5. Wait for installation to finish.
6. Run the command.

   ```npm
   node .
   ```

7. An (unsecured-) audiofile-api is now running on [localhost:3000](localhost:3000), next to that a tunnel to which an external client can connect to is automatically created and logged in the terminal.
