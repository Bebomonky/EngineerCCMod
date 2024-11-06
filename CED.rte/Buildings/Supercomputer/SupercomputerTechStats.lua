require("MasterList")

function Create(self)
	self.CEDAvailableTechnology = {}
	self.CEDAvailableTechnology.Xarix = {}
	self.CEDAvailableTechnology.Khrabarovsk = {}
	self.CEDAvailableTechnology.Vossberg = {}

	-------  XARIX  -------
	local i = 1;
	self.CEDAvailableTechnology.Xarix[i] = CEDMasterList.Technology.Xarix.XarixADoctra;
	i = i + 1;
	-------  KHRABAROVSK  -------
	local i = 1;
    self.CEDAvailableTechnology.Khrabarovsk[i] = CEDMasterList.Technology.Khrabarovsk.SPr40;
	-------  VOSSBERG  -------
	local i = 1;
    self.CEDAvailableTechnology.Vossberg[i] = CEDMasterList.Technology.Vossberg.Hammerhead;
    i = i + 1;
end