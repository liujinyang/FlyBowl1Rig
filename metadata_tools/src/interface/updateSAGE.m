function updateSAGE
% updateSAGE:  updates all files (linenames.txt, effectors.txt,
% noteskeywords.txt) used by jfrc_metadata_tools by download the current
% values from SAGE.

fprintf('updating linenames.txt ... ');
updateLinenames;
fprintf('done\n');

fprintf('updating effectors.txt ... ');
updateEffectors;
fprintf('done\n');

fprintf('updateing notes_keywords.txt ... ');
updateNotesKeywords;
fprintf('done\n');