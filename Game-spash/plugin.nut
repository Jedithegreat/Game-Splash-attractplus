/*
Game- splash plugin

Alows you to add a splash before a game is launched

options:

#0 toggle on / off plugin

#1 set a folder that points to were you keep your game splashes you want ie: clear logos

#2 match by Rom Name or Title

#3 Use emulator sub folders

#4 Set time duration for the splash to display for 

#5 set a fall back splash to display if a game has no match

#5 Scaling Fit or Stretch
*/

class UserConfig </ help="Shows a PNG/JPG named after the game when it launches" />
{
    </ label="Splash Folder",
       help="Folder containing splash images named after the games (e.g. sf2.png)",
       is_path=true,
       order=1 />
    folder="";

    </ label="Match By",
       help="Use the ROM name or the game title for the filename",
       options="Rom Name,Title",
       order=2 />
    match_by="Rom Name";

    </ label="Use Emulator Subfolders",
       help="Look in <folder>/<emulator>/ instead of <folder>/",
       options="No,Yes",
       order=3 />
    use_emulator_subfolder="No";

    </ label="Display Time (ms)",
       help="How long the splash stays up before the game launches",
       order=4 />
    duration="3000";

    </ label="Fallback Image",
       help="Optional full path to an image used when no match is found",
       order=5 />
    fallback="";

    </ label="Scaling",
       help="Fit keeps the aspect ratio, Stretch fills the whole screen",
       options="Fit,Stretch",
       order=6 />
    scaling="Fit";
}

local config = fe.get_config();

local splash = fe.add_image("", 0, 0, fe.layout.width, fe.layout.height);
splash.zorder = 10000;
splash.visible = false;
splash.preserve_aspect_ratio = (config["scaling"] == "Fit");

local splash_time = 3000;
try { splash_time = config["duration"].tointeger(); } catch (e) {}

local extensions = [ "png", "jpg", "jpeg" ];
local active = false;  

function find_splash()
{
    local folder = config["folder"];
    if (folder == "")
        return "";

    local last = folder.slice(folder.len() - 1);
    if (last != "/" && last != "\\")
        folder += "/";

    if (config["use_emulator_subfolder"] == "Yes")
        folder += fe.game_info(Info.Emulator) + "/";

    local name = (config["match_by"] == "Title")
        ? fe.game_info(Info.Title)
        : fe.game_info(Info.Name);

    foreach (ext in extensions)
    {
        local path = folder + name + "." + ext;
        if (fe.path_test(path, PathTest.IsFile))
            return path;
    }

    if (config["fallback"] != "" && fe.path_test(config["fallback"], PathTest.IsFile))
        return config["fallback"];

    return "";
}

function launch_splash(ttype, var, ttime)
{
    if (ttype == Transition.ToGame)
    {
        
        if (!active && ttime == 0)
        {
            local img = find_splash();
            if (img == "")
                return false;          

            splash.file_name = img;
            splash.visible = true;
            active = true;
        }

        if (active && ttime < splash_time)
            return true;                

        splash.visible = false;
        active = false;
        return false;                   
    }

    if (ttype == Transition.FromGame)
    {
        splash.visible = false;
        active = false;
    }

    return false;
}

fe.add_transition_callback("launch_splash");