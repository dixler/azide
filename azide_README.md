<img src="https://raw.githubusercontent.com/go0d/azide/master/preview.gif" /> 
azide - a zsh ide
shoehorned together by: Kyle Dixler

This project is basically a set of zsh tools

This project is heavily based on hchbaw's auto-fu and is in the public domain

   https://github.com/hchbaw/auto-fu.zsh

I have included the original readme since it has more documentation of
behaviors and because I'm lazy

The reason for making this was that auto-fu worked alright, but conflicted a
lot with my .zshrc so I patched it and changed it a little more. The completion
was little too complicated for me or clashed with the grml zshrc that I liked
so I removed it using.

This project also includes a modified version of the grml zshrc

   https://grml.org/zsh/

To the paranoid, feel free to diff it with mine. I'm some random guy on the 
internet, I did change some stuff and this is a really long file, but there
are also a lot of cool things in there.


included are my personal dotfiles and azide.zsh

in .zshrc add:
   source path/to/auto-fu.zsh
   source path/to/grml.zsh



