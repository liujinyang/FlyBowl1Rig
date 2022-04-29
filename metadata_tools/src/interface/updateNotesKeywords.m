function updateNotesKeywords
% updateNotesKeywords: updates the notekeywords.txt file used by jfrc_metadata_tools
% by downloading the current list of effectory names from SAGE.
%
% Usage:  updateNotesKeywords();
%
cacher = SAGEDataCacher();
cacher.updateNotesKeywordsFile();
end