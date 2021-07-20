# Formspec Editor
## REALTIME formspec viewer/editor "game" for minetest

![formspec editor preview](preview.png)

## Getting Started 

The file *formspec.spec* in your:

```minetest_folder/games/formspec_editor/mods/formspec_edit```

contains a formspec you can edit and see updates of in real time.
Simply add the game to MT, add ```formspec_edit``` to your ```secure.trusted_mods``` settings,
load up a level of *Formspec Editor*, and you will be greeted with the *formspec.spec* formspec. 

- To make edits, open the file (formspec.spec) in your editor of choice and make changes as you see fit. When you hit save, the formspec will auto-update. Best when used side by side. 
- To exit just hit <escape> or use a button_exit[] button. Both send the
fields.quit message.
- You can test with images if you want, adding a "textures" folder to the 
formspec_edit gamemod folder, otherwise images will default to random colors.

