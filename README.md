# Solix ESP LIB

![Full Preview](https://github.com/Ifykyklolololol/images/blob/main/FullPreview.png?raw=true)

### If Your Seeing This You Should Already Have The ESP SOURCE In The Solix Group Chat!


## Features

### BoundingBox
![BoundingBox Preview](https://github.com/Ifykyklolololol/images/blob/main/BoundingBoxPreview.png?raw=true)

```

    Enabled               -> true / false
    DynamicBox            -> true / false
    IncludeAccessories    -> true / false
    
    Color                 -> { Color3, Color3 }
    Transparency          -> { number, number }
    Rotation              -> 0–360 degrees

    Glow
        Enabled           -> true / false
        Color             -> { Color3, Color3 }
        Transparency      -> { number, number }
        Rotation          -> 0–360 degrees

    Fill
        Enabled           -> true / false
        Color             -> { Color3, Color3 }
        Transparency      -> { number, number }
        Rotation          -> 0–360 degrees
        
```

### Bars
![BoundingBox Preview](https://github.com/Ifykyklolololol/images/blob/main/BarsPreview.png?raw=true)

```

    Enabled               -> true / false
    Position              -> "Left" / "Right" / "Top" / "Bottom"

    Color                 -> { Color3, Color3, Color3 }
                            (3-point gradient)

    Type(Player)          -> returns 0–1 value (bar fill amount)

    Text
        Enabled           -> true / false
        FollowBar         -> true / false
        Ending            -> string ("" or "%", etc)
        Position          -> "Left" / "Right" / "Top" / "Bottom"
                              (ignored if FollowBar = true)
        Color             -> Color3
        Transparency      -> number (0–1)

        Type(Player)
            Returns:
                value      -> number shown
                visibility -> true/false (auto visibility)
                
```



❤️ Credits

Developed by RelixEnd
For the Solix Team
