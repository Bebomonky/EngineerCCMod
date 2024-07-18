require("MasterList")

function Create(self)
	self.CEDTechnologyRate = 10
	self.CEDAvailableTechnology = {}

	-------  TECHNOLOGY  -------
	local i = 1
	self.CEDAvailableTechnology[i] = CEDMasterList.Technology.PlinkTurret
	i = i + 1
    self.CEDAvailableTechnology[i] = CEDMasterList.Technology.Atmo_coagulator
    i = i + 1
end