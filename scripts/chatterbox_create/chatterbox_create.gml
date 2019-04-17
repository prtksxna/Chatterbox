/// @param [filename]

var _filename = ((argument_count > 0) && (argument[0] != undefined))? argument[0] : global.__chatterbox_default_file;

if (!is_string(_filename))
{
    show_error("Chatterbox:\nYarn .json filenames must be strings (Got \"" + string(_filename) + "\")\n ", false);
    return undefined;
}

if (!ds_map_exists(global.__chatterbox_file_data, _filename))
{
    show_error("Chatterbox:\nCannot find Yarn .json \"" + _filename + "\"\n ", false);
    return undefined;
}

//Create the Chatterbox data structure
var _chatterbox = ds_list_create();

_chatterbox[| __CHATTERBOX.__SECTION0                 ] = "-- Parameters --";
_chatterbox[| __CHATTERBOX.FILENAME                   ] = _filename;
_chatterbox[| __CHATTERBOX.TITLE                      ] = undefined;
_chatterbox[| __CHATTERBOX.ORIGIN_X                   ] = 0;
_chatterbox[| __CHATTERBOX.ORIGIN_Y                   ] = 0;

_chatterbox[| __CHATTERBOX.__SECTION1                 ] = "-- Text Template --";
_chatterbox[| __CHATTERBOX.TEXT_MIN_LINE_HEIGHT       ] = undefined;
_chatterbox[| __CHATTERBOX.TEXT_MAX_LINE_WIDTH        ] = undefined;
_chatterbox[| __CHATTERBOX.TEXT_STARTING_COLOUR       ] = undefined;
_chatterbox[| __CHATTERBOX.TEXT_STARTING_FONT         ] = undefined;
_chatterbox[| __CHATTERBOX.TEXT_STARTING_HALIGN       ] = undefined;
_chatterbox[| __CHATTERBOX.TEXT_DATA_FIELDS           ] = undefined;
_chatterbox[| __CHATTERBOX.TEXT_FADE_IN_SPEED         ] = 1;
_chatterbox[| __CHATTERBOX.TEXT_FADE_IN_SMOOTHNESS    ] = 0;
_chatterbox[| __CHATTERBOX.TEXT_FADE_IN_METHOD        ] = SCRIBBLE_TYPEWRITER_WHOLE;
_chatterbox[| __CHATTERBOX.TEXT_FADE_OUT_SPEED        ] = 1;
_chatterbox[| __CHATTERBOX.TEXT_FADE_OUT_SMOOTHNESS   ] = 0;
_chatterbox[| __CHATTERBOX.TEXT_FADE_OUT_METHOD       ] = SCRIBBLE_TYPEWRITER_WHOLE;

_chatterbox[| __CHATTERBOX.__SECTION2                 ] = "-- Option Template --";
_chatterbox[| __CHATTERBOX.OPTION_MIN_LINE_HEIGHT     ] = undefined;
_chatterbox[| __CHATTERBOX.OPTION_MAX_LINE_WIDTH      ] = undefined;
_chatterbox[| __CHATTERBOX.OPTION_STARTING_COLOUR     ] = undefined;
_chatterbox[| __CHATTERBOX.OPTION_STARTING_FONT       ] = undefined;
_chatterbox[| __CHATTERBOX.OPTION_STARTING_HALIGN     ] = undefined;
_chatterbox[| __CHATTERBOX.OPTION_DATA_FIELDS         ] = undefined;
_chatterbox[| __CHATTERBOX.OPTION_FADE_IN_SPEED       ] = 1;
_chatterbox[| __CHATTERBOX.OPTION_FADE_IN_SMOOTHNESS  ] = 0;
_chatterbox[| __CHATTERBOX.OPTION_FADE_IN_METHOD      ] = SCRIBBLE_TYPEWRITER_WHOLE;
_chatterbox[| __CHATTERBOX.OPTION_FADE_OUT_SPEED      ] = 1;
_chatterbox[| __CHATTERBOX.OPTION_FADE_OUT_SMOOTHNESS ] = 0;
_chatterbox[| __CHATTERBOX.OPTION_FADE_OUT_METHOD     ] = SCRIBBLE_TYPEWRITER_WHOLE;

_chatterbox[| __CHATTERBOX.__SECTION3                 ] = "-- State --";
_chatterbox[| __CHATTERBOX.ITERATION                  ] = -1;
_chatterbox[| __CHATTERBOX.SUSPENDED                  ] = false;
_chatterbox[| __CHATTERBOX.HIGHLIGHTED                ] = 0;
_chatterbox[| __CHATTERBOX.INITIALISED                ] = false;
_chatterbox[| __CHATTERBOX.VARIABLES                  ] = ds_map_create();

_chatterbox[| __CHATTERBOX.__SECTION4                 ] = "-- Children --"
_chatterbox[| __CHATTERBOX.TEXT_LIST                  ] = ds_list_create();
_chatterbox[| __CHATTERBOX.OPTION_LIST                ] = ds_list_create();
_chatterbox[| __CHATTERBOX.OLD_TEXT_LIST              ] = ds_list_create();
_chatterbox[| __CHATTERBOX.OLD_OPTION_LIST            ] = ds_list_create();

ds_list_mark_as_map( _chatterbox, __CHATTERBOX.VARIABLES      );
ds_list_mark_as_list(_chatterbox, __CHATTERBOX.TEXT_LIST      );
ds_list_mark_as_list(_chatterbox, __CHATTERBOX.OPTION_LIST    );
ds_list_mark_as_list(_chatterbox, __CHATTERBOX.OLD_TEXT_LIST  );
ds_list_mark_as_list(_chatterbox, __CHATTERBOX.OLD_OPTION_LIST);

return _chatterbox;