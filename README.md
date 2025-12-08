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

### Distance
![BoundingBox Preview](https://github.com/Ifykyklolololol/images/blob/main/DistancePreview.png?raw=true)

```

    Enabled               -> true / false
    Ending                -> "st" / "m" / custom string
    Position              -> "Top" / "Bottom" / "Left" / "Right"

    Color                 -> Color3
    Transparency          -> number (0–1)

                
```

### Name
![BoundingBox Preview](https://github.com/Ifykyklolololol/images/blob/main/NamePreview.png?raw=true)

```

    Enabled               -> true / false
    UseDisplay            -> true / false
                             (DisplayName or Username)

    Position              -> "Top" / "Bottom" / "Left" / "Right"
    Color                 -> Color3
    Transparency          -> number (0–1)
                
```

### Weapon / Tool
![BoundingBox Preview](https://github.com/Ifykyklolololol/images/blob/main/ToolPreview.png?raw=true)

```

    Enabled               -> true / false
    UseDisplay            -> true / false
                             (DisplayName or Username)

    Position              -> "Top" / "Bottom" / "Left" / "Right"
    Color                 -> Color3
    Transparency          -> number (0–1)
                
```

### Flags
![BoundingBox Preview](https://github.com/Ifykyklolololol/images/blob/main/FlagsPreview.png?raw=true)

```

    Enabled               -> true / false
    Position              -> "Left" / "Right"

    Color                 -> Color3
    Transparency          -> number (0–1)

    Type(Player)
        Returns a table of strings representing states:
             Example defaults:
                 "moving"    -> player is walking
                 "jumping"   -> player is jumping

    You can add ANY custom flags by inserting more strings into the returned table.
                
```




❤️ Credits

Developed by RelixEnd
For the Solix Team
