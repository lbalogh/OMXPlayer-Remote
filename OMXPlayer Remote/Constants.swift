//
//  Constants.swift
//  OMXPlayer Remote
//
//  Created by Ludovic Balogh on 01.08.15.
//  Copyright © 2015 Ludovic Balogh. All rights reserved.
//

import Foundation

let kListDirCommand                 = "list_dir";
let kIsPlayingCommand               = "is_playing";
let kPlayingFinishedCommand         = "playing_finished";
let kPlayCommand                    = "play";
let kDeleteFileCommand              = "delete_file";
let kDeleteFolderCommand            = "delete_folder";
let kPauseCommand                   = "pause";
let kStopCommand                    = "stop";
let kSeekBackwardCommand            = "seek_backward";
let kSeekForwardCommand             = "seek_forward";
let kSeekFastBackwardCommand        = "seek_fast_backward";
let kSeekFastForwardCommand         = "seek_fast_forward";
let kPoweroffCommand                = "poweroff";
let kRebootCommand                  = "reboot";
let kPreviousSubtitleStreamCommand  = "previous_subtitle_stream";
let kNextSubtitleStreamCommand      = "next_subtitle_stream";
let kIncreaseSubtitleDelayCommand   = "increase_subtitle_delay";
let kDecreaseSubtitleDelayCommand   = "decrease_subtitle_delay";
let kPreviousAudioStreamCommand     = "previous_audio_stream";
let kNextAudioStreamCommand         = "next_audio_stream";

let kCommandKey                     = "command";
let kFilesKey                       = "files";
let kDirsKey                        = "dirs";
let kPathKey                        = "path";

let kHostIpAddressKey               = "host_ip_address";
let kHostPortKey                    = "host_port";

let kReloadFileListNotification     = "reloadFileList"

let kAppGroupIdentifier             = "group.com.balogh.OMXPlayer-Remote"