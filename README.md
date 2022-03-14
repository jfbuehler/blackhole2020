# ✨ Blackhole 2020 ✨

Blackhole is an open-source secure file eraser. Make your files vanish in style!

![blackhole_store_animation_try1](https://user-images.githubusercontent.com/13276545/155787068-310ab850-5a65-42e8-bd23-9d3133d406ea.gif)


## About

I designed this project in my spare time...so it is as such -- no promises of features or perfection -- but if it brings more joy to the world, then I am glad. It certainly brings me joy! 

That said, I strive to keep the core functionality bug-free and working solid. 
To date on MacOS the secure erasure has been tested on Terabytes of my own SSD data.

Windows, however, is still a major work-in-progress and needs some more loving to keep up. IMO this is a testament to the major differences in developing for the two operating systems in this 3rd decade of the 21st century -- 2022. 

I use this project as a practice ground for best-practices, coding standards, learning new techniques, and expressing plain ol' coding joy. 
So, its my hope that while it may be small in scope, the code is tight and well designed, bug free (mostly) and achieves its purpose with grace.
That said, if you do stumble upon this repo, you are free to explore and suggest or fork it and never talk to me :) Whatever your heart desires.
May this project and the way I've implemented things inspire you to great places!

Future growth includes:
- Adding automated tests
- Adding localizations 
- Sprucing up the animations
- Maybe Windows catches up to MacOS, one day..

## Installation

See detailed instructions for MacOS and Windows separately.

## MacOS

Be sure to have cocoapods installed on your system. 

```bash
pod install
```

Then build the Xcode workspace project for the MacOS target. Yea...it's that simple! 

It is tested working well on both x86 Intel Macs and M1 Apple Silicon. 

## Windows

```bash

Windows.... is quite the fiasco. UWP file access makes everything challenging. Hopefully this project is still helpful in all its flawed beauty. 

You will need Visual Studio 2019+ and UWP C# frameworks installed. Open the solution file Blackhole.sln and see if it builds in Debug mode. 

Currently, there's no tested working installer or Release build (tho it may work anyway). 

UWP ended up being a big disaster in regards to file system access. It has taken so much time, effort, frustration, and still refused to work.
You will notice the Windows app lacks most of the nice featurse of the MacOS side (file counters, progress bars, moving animations, etc..)
That's how much time got eaten up by the UWP "blackhole" >< 

It's hard to put out not-great code into the world, even when it's free and a side project. BUT I didn't design this to be hidden away in a cave somewhere! 

The Windows app *does* work, and it also shows a lot of ways that don't (commented out code heavy). 

There are a few paths forward (falling back to C# WPF to name the first), it is just a bit more complex than originally desired. Such is life, yes? :) 


```

## Contributing
Pull requests are welcome!! 😎 For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License
[APACHE](https://choosealicense.com/licenses/apache-2.0/)
