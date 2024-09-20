require("MasterList")

function Create(self)
	self.CEDConstructRange = 100;
	
	self.CEDAvailableConstructs = {};
	self.CEDAvailableConstructs.Actors = {};
	self.CEDAvailableConstructs.Guns = {};
	-------  ACTORS  -------
	local i = 1;
	self.CEDAvailableConstructs.Actors[i] = CEDMasterList.Actors.Behemoth
	i = i + 1;
	
	-------  GUNS  -------
	local i = 1;
	self.CEDAvailableConstructs.Guns[i] = CEDMasterList.Guns.XarixVidara
	i = i + 1;
	
end