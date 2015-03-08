-- Last Update : 11/03/2006

if GetLocale() == "koKR" then

	-- General
	MAPNOTES_NAME = "MapNotes";
	MAPNOTES_ADDON_DESCRIPTION = "세계 지도에 메모 시스템을 추가합니다.";
	MAPNOTES_DOWNLOAD_SITES = "다운로드 사이트에서 README 화일을 읽어주세요.";

	-- Interface Configuration
	MAPNOTES_WORLDMAP_HELP_1 = "지도 축소: 마우스 오른쪽 버튼";
	MAPNOTES_WORLDMAP_HELP_2 = "지도 확대: 마우스 왼쪽 버튼";
	MAPNOTES_WORLDMAP_HELP_3 = MAPNOTES_NAME.." 메뉴 열기: <컨트롤>+마우스 오른쪽 버튼";
	MAPNOTES_CLICK_ON_SECOND_NOTE = "|cFFFF0000"..MAPNOTES_NAME..":|r 메모 삭제 / 선긋기를 할 두번째 메모를 선택하세요";

	MAPNOTES_NEW_MENU = MAPNOTES_NAME;
	MAPNOTES_NEW_NOTE = "메모 만들기";
	MAPNOTES_MININOTE_OFF = "미니맵 메모 표시 해제";
	MAPNOTES_OPTIONS = "설정";
	MAPNOTES_CANCEL = "취소";

	MAPNOTES_POI_MENU = MAPNOTES_NAME;
	MAPNOTES_EDIT_NOTE = "메모 편집";
	MAPNOTES_MININOTE_ON = "미니맵에 메모 표";
	MAPNOTES_SPECIAL_ACTIONS = "메모 삭제 / 선긋기";
	MAPNOTES_SEND_NOTE = "메모 보내기";

	MAPNOTES_SPECIALACTION_MENU = "메모 삭제 / 선긋기";
	MAPNOTES_TOGGLELINE = "메모간 선긋기";
	MAPNOTES_DELETE_NOTE = "메모 삭제";

	MAPNOTES_EDIT_MENU = "메모 편집";
	MAPNOTES_SAVE_NOTE = "저장";
	MAPNOTES_EDIT_TITLE = "제목 (필수 입력사항):";
	MAPNOTES_EDIT_INFO1 = "내용 1 (선택 입력사항):";
	MAPNOTES_EDIT_INFO2 = "내용 2 (선택 입력사항):";
	MAPNOTES_EDIT_CREATOR = "작성자 (선택 입력사항):";

	MAPNOTES_SEND_MENU = "메모 보내기";
	MAPNOTES_SLASHCOMMAND = "보내기 모드 변경";
	MAPNOTES_SEND_TITLE = "메모 보내기:";
	MAPNOTES_SEND_TIP = MAPNOTES_NAME.." 기능을 사용하는 사용자들에게 메모를 보낼 수 있습니다.";
	MAPNOTES_SEND_PLAYER = "플레이어 이름 입력:";
	MAPNOTES_SENDTOPLAYER = "한사람에게 전송";
	MAPNOTES_SENDTOPARTY = "파티원에게 전송";
	MAPNOTES_SHOWSEND = "보내기 모드 변경";
	MAPNOTES_SEND_SLASHTITLE = "/ 명령어 보기:";
	MAPNOTES_SEND_SLASHTIP = "다음의 명령을 CTRL+A로 선택하시고 CTRL+C로 카피하신 후\n게시판 등에 올려서 정보를 공유할 수 있습니다.";
	MAPNOTES_SEND_SLASHCOMMAND = "/ 명령어:";

	MAPNOTES_OPTIONS_MENU = "옵션";
	MAPNOTES_SAVE_OPTIONS = "저장";
	MAPNOTES_OWNNOTES = "자기가 작성한 맵 메모 표시";
	MAPNOTES_OTHERNOTES = "다른 사용자로부터 받은 맵 메모 표시";
	MAPNOTES_HIGHLIGHT_LASTCREATED = "|cFFFF0000빨간색|r으로 마지막에 작성한 메모 표시";
	MAPNOTES_HIGHLIGHT_MININOTE = "미니맵에 표시할 메모를 |cFF6666FF파란색|r으로 표시";
	MAPNOTES_ACCEPTINCOMING = "다른 사용자로부터 메모받기 허용";
	MAPNOTES_INCOMING_CAP = "만들수 있는 메모가 5개 미만일경우 허용 않함";
	MAPNOTES_AUTOPARTYASMININOTE = "파티원이 사용하고 있는 미니맵 메모 자동 공유"

	MAPNOTES_CREATEDBY = "님께서 작성";
	MAPNOTES_CHAT_COMMAND_ENABLE_INFO = "이 명령어는 웹사이트 등에 올려진 메모를 등록할 때 사용하는 명령어 입니다.";
	MAPNOTES_CHAT_COMMAND_ONENOTE_INFO = "옵션 설정 내역을 무시하고 이후의 메모를 한번만 전송받는 것을 허용합니다.";
	MAPNOTES_CHAT_COMMAND_MININOTE_INFO = "이후에 받는 맵 메모는 미니맵에도 표시합니다. (지도에도 추가됩니다):";
	MAPNOTES_CHAT_COMMAND_MININOTEONLY_INFO = "이후에 받는 맵 메모를 미니맵에만 표시합니다. (지도에는 추가되지 않습니다).";
	MAPNOTES_CHAT_COMMAND_MININOTEOFF_INFO = "미니맵에 메모 표시 기능을 해제합니다.";
	MAPNOTES_CHAT_COMMAND_MNTLOC_INFO = "지도에 좌표를 표시합니다.";
	MAPNOTES_CHAT_COMMAND_QUICKNOTE = "현재 위치에 맵 메모를 작성합니다.";
	MAPNOTES_CHAT_COMMAND_QUICKTLOC = "좌표 정보를 입력하여 맵 메모를 작성합니다.";

	MAPNOTES_CHAT_COMMAND_IMPORT_METAMAP = "Imports MetaMapNotes. Intended for people migrating to MapNotes.\nMetaMap must be Installed and Enabled for the command to work. Then Un-Install MetaMap.\nWARNING : Intended for new users. May over-write existing notes."; --Telic_4
	MAPNOTES_CHAT_COMMAND_IMPORT_ALPHAMAP = "Import AlphaMap's Instance Notes : Requires AlphaMap (Fan's Update) to be Installed and Enabled";		--Telic_4

	MAPNOTES_MAPNOTEHELP = "이 명령어는 맵 메모를 만드는 데 쓰입니다.";
	MAPNOTES_ONENOTE_OFF = "맵 메모 허용상태: 허용않함";
	MAPNOTES_ONENOTE_ON = "맵 메모 허용상태: 허용";
	MAPNOTES_MININOTE_SHOW_0 = "미니맵 표시 여부: 허용않함";
	MAPNOTES_MININOTE_SHOW_1 = "미니맵 표시 여부: 허용";
	MAPNOTES_MININOTE_SHOW_2 = "미니맵 표시 여부: 미니맵에만 표시";
	MAPNOTES_DECLINE_SLASH = "메모를 만들 수 없습니다. |cFFFFD100%s|r 지역에 너무 많은 메모가 있습니다.";
	MAPNOTES_DECLINE_SLASH_NEAR = "메모를 만들 수 없습니다.  |cFFFFD100%s|r 지역의 |cFFFFD100%q|r 메모가 너무 가까이 있습니다.";
	MAPNOTES_DECLINE_GET = "|cFFFFD100%s|r님으로부터 메모를 받을 수 없습니다: |cFFFFD100%s|r 지역에 너무 많은 메모가 있거나, 옵션에서 허용하지 않음으로 설정되어 있습니다.";
	MAPNOTES_ACCEPT_SLASH = "|cFFFFD100%s|r 지역에 메모를 추가합니다.";
	MAPNOTES_ACCEPT_GET = "|cFFFFD100%s|r님으로부터 |cFFFFD100%s|r 지역에 메모를 전송받았습니다.";
	MAPNOTES_PARTY_GET = "|cFFFFD100%s|r님께서 모든 파티원에게 |cFFFFD100%s|r 지역에 메모를 전송하였습니다.";
	MAPNOTES_DECLINE_NOTETONEAR = "|cFFFFD100%s|r님께서 당신에게 |cFFFFD100%s|r지역에 메모를 보냈습니다, 하지만 |cFFFFD100%q|r 메모와 자리가 겹쳐 생성하지 못했습니다.";
	MAPNOTES_QUICKNOTE_NOTETONEAR = "메모를 만들 수 없습니다. |cFFFFD100%s|r 메모와 너무 가까운 곳에 있습니다.";
	MAPNOTES_QUICKNOTE_NOPOSITION = "메모를 만들 수 없습니다: 현재 위치 정보를 알 수 없습니다.";
	MAPNOTES_QUICKNOTE_DEFAULTNAME = "빠른 메모";
	MAPNOTES_QUICKNOTE_OK = "|cFFFFD100%s|r 지역에 메모를 작성합니다.";
	MAPNOTES_QUICKNOTE_TOOMANY = "|cFFFFD100%s|r 지역에 이미 너무 많은 메모가 있습니다.";
	MAPNOTES_DELETED_BY_NAME = "Deleted all "..MAPNOTES_NAME.." with creator |cFFFFD100%s|r and name |cFFFFD100%s|r.";
	MAPNOTES_DELETED_BY_CREATOR = "Deleted all "..MAPNOTES_NAME.." with creator |cFFFFD100%s|r.";
	MAPNOTES_QUICKTLOC_NOTETONEAR = "메모를 만들 수 없습니다. 지정한 위치가 |cFFFFD100%s|r 메모에 너무 가깝습니다.";
	MAPNOTES_QUICKTLOC_NOZONE = "메모를 만들 수 없습니다: 지정한 위치 정보를 알 수 없습니다.";
	MAPNOTES_QUICKTLOC_NOARGUMENT = "사용 예: '/좌표작성 좌표(xx,yy) [아이콘] [제목]'.";
	MAPNOTES_SETMININOTE = "메모를 미니맵에 표시";
	MAPNOTES_THOTTBOTLOC = "Thottbot 좌표로 작성";
	MAPNOTES_PARTYNOTE = "파티원들에게 전송된 맵 메모";

	MAPNOTES_CONVERSION_COMPLETE = MAPNOTES_VERSION.." - Conversion complete. Please check your notes.";		-- ??

	MAPNOTES_TRUNCATION_WARNING = "The Note Text being Sent had to be truncated";				-- ??

	MAPNOTES_IMPORT_REPORT = "개의 메모를 전송받았습니다";--" Notes Imported";								-- ??
	MAPNOTES_NOTESFOUND = "개의 메모를 찾았습니다.";--" Note(s) Found";									-- ??

	-- Drop Down Menu
	MAPNOTES_SHOWNOTES = "메모 표시";
	MAPNOTES_DROPDOWNTITLE = MAPNOTES_NAME;
	MAPNOTES_DROPDOWNMENUTEXT = "빠른 설정";

	MAPNOTES_WARSONGGULCH = "전쟁노래 협곡";
	MAPNOTES_ALTERACVALLEY = "알터랙 계곡";
	MAPNOTES_ARATHIBASIN = "아라시 분지";
	MAPNOTES_STORMWIND = "Stormwind";

	MAPNOTES_COSMIC = "Cosmic";


	-- Coordinates
	MAPNOTES_MAP_COORDS = "Map Coords";
	MAPNOTES_MINIMAP_COORDS = "Minimap Coords";


	-- MapNotes Target & Merging
	MAPNOTES_MERGED = "MapNote Merged for : ";
	MAPNOTES_MERGE_DUP = "MapNote already exists for : ";
	MAPNOTES_MERGE_WARNING = "You must have something targetted to merge notes.";

	BINDING_HEADER_MAPNOTES = "MapNotes";
	BINDING_NAME_MN_TARGET_NEW = "QuickNote/TargetNote";
	BINDING_NAME_MN_TARGET_MERGE = "Merge Target Note";

	MN_LEVEL = "레벨";

	-- Magellan Style LandMarks
	MAPNOTES_LANDMARKS = "Landmarks";				-- Landmarks, as in POI, or Magellan
	MAPNOTES_LANDMARKS_CHECK = "Auto-MapNote "..MAPNOTES_LANDMARKS;
	MAPNOTES_DELETELANDMARKS = "Delete "..MAPNOTES_LANDMARKS;
	MAPNOTES_MAGELLAN = "(~Magellan)";
	MAPNOTES_LM_CREATED = " MapNotes Created in ";
	MAPNOTES_LM_MERGED = " MapNotes Merged in ";
	MAPNOTES_LM_SKIPPED = " MapNotes not Noted in ";
	MAPNOTES_LANDMARKS_NOTIFY = MAPNOTES_LANDMARKS.." Noted in ";

end