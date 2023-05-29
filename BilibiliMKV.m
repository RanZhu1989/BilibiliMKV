% B站安卓客户端缓存视频提取 - 自动化脚本
% Author: Ran Zhu @ Southeast Unitversity
% V 0.1

% 视频信息在纯数字文件夹\分P\entry.json文件中
% 其中title为视频标题，quality_pithy_description为分辨率，owner_name为UP主姓名，bvid为视频号
% 依赖项: ------- # JSONLab: compact, portable, robust JSON/binary-JSON encoder/decoder for MATLAB/Octave  See  https://github.com/fangq/jsonlab 
%                       # MKVToolNix – Matroska tools for Linux/Unix and Windows           See https://www.matroska.org/

function BilibiliMKV(input_path, output_path)
% input_path = 'E:\Test\'; % 用户输入的缓存存放位置
% output_path = 'E:\Outputs\'; % 保存位置
mkdir(output_path);
% title_list = {};


% 获取文件夹中所有子文件夹
subfolders = dir(input_path);
subfolders = subfolders([subfolders(:).isdir]); % 只保留子文件夹
subfolders = subfolders(~ismember({subfolders(:).name},{'.','..'})); % 去掉'.'和'..'

% 遍历每个子文件夹
for i = 1:length(subfolders)
    % 获取子文件夹路径
    subfolder_path = fullfile(input_path, subfolders(i).name);
    
    % 获取子文件夹中所有的子文件夹
    subsubfolders = dir(subfolder_path);
    subsubfolders = subsubfolders([subsubfolders(:).isdir]); % 只保留子文件夹
    subsubfolders = subsubfolders(~ismember({subsubfolders(:).name},{'.','..'})); % 去掉'.'和'..'
    
    % 遍历每个子文件夹中的子文件夹
    for j = 1:length(subsubfolders)
        % 获取子文件夹中的子文件夹路径
        subsubfolder_path = fullfile(subfolder_path, subsubfolders(j).name);
        subsubsubfolders = dir(subsubfolder_path);
         subsubsubfolders = subsubsubfolders([subsubsubfolders(:).isdir]); % 只保留子文件夹
        subsubsubfolders = subsubsubfolders(~ismember({subsubsubfolders(:).name},{'.','..'})); % 去掉'.'和'..'
        subsubsubfolder_path = fullfile(subsubfolder_path, subsubsubfolders(1).name);
        % 获取文件夹中的entry.json中的内容
        entry_file_path = fullfile(subsubfolder_path, 'entry.json');
        entry_file = loadjson(entry_file_path);
        title = regexprep(entry_file.title, '[^\w]+', ''); % 需要加入正则表达式去掉标点 否则奇怪的文件名会出错
        
        % 可能存在分P
         if isfield(entry_file, 'page_data')
            part = num2str(entry_file.page_data.page);
        else
            part = '无分P';
         end
        % 可能有分辨率不存在的问题
        if isfield(entry_file, 'quality_pithy_description')
            quality_pithy_description = entry_file.quality_pithy_description;
        else
            quality_pithy_description = '未知分辨率';
        end
        % 可能有UP主信息丢失问题
        if isfield(entry_file, 'owner_name')
            owner_name =  regexprep(entry_file.owner_name, '[^\w]+', '');% 需要加入正则表达式去掉标点 否则奇怪的UP主的名字会出错
        else
            owner_name = '未知UP主';
        end
        
        entry_content = ['[分P=' part ']_' title '_' quality_pithy_description '_UP主=' owner_name '_BVid=' num2str(entry_file.bvid)];
        
        % 将当前子文件夹中子文件夹中的audio.m4s和video.m4s重命名为{视频标题+UP主姓名+分辨率+AV号.mp3和对应的*.mp4
        audio_file_path = fullfile(subsubsubfolder_path, 'audio.m4s');
        video_file_path = fullfile(subsubsubfolder_path, 'video.m4s');
        mkv_file_path = fullfile(subsubsubfolder_path,  [entry_content, '.mkv']);
        new_audio_file_path = fullfile(subsubsubfolder_path, [entry_content, '.mp3']);
        new_video_file_path = fullfile(subsubsubfolder_path, [entry_content, '.mp4']);
        movefile(audio_file_path, new_audio_file_path);
        movefile(video_file_path, new_video_file_path);
        
          % 调用mkvmerge将MP3和MP4合并为MKV文件
        command_mkvmerge = ['mkvmerge -o ' mkv_file_path ' ' new_audio_file_path ' ' new_video_file_path];
        system(command_mkvmerge);
        movefile(mkv_file_path, [output_path entry_content '.mkv']);        
    end
end
end


