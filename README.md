# Stat roller for BG2EE

See this [blog post](https://clux.dev/post/2022-04-12-baldurs-roll/) for more info.

## Usage

Run in a terminal while you have your BG2EE window open somewhere at the ability score screen (with at least 1024x768 size on the window).

Then run:

```sh
./roll.sh
```

this will move your mouse and click on your behalf. To stop, press yourself at the reroll button a few times to cancel.

Once the script exists (happens if you got more than our roll table have data for, i.e. > 103, or you moved away from the screen), you'll get a summary of outputs showing you how many of each roll you encountered.

## Rolls

The rolls folder is here for sanity reasons. You can take the `md5sum` of the images and you can re-populate the roll table in the script. The files are not needed.

If you get a roll over 103, please submit a PR along with a screenshot + the tiny screenshot the script writes for unknown rolls.
