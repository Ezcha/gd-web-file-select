# gd-web-file-select

A simple script for Godot that allows a local file to be selected and read.

## How to use

1. Include the `web_file_select.gd` file anywhere in your Godot project.
2. Apply it to a `Node`
3. Set the file extension property
4. Connect the selected signal, a `PackedByteArray` containing the files data is passed as the first argument
5. Call `open()` on the new node
