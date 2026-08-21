---@meta _
C_HousingPhotoSharing = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingPhotoSharing.BeginAuthorizationFlow)
function C_HousingPhotoSharing.BeginAuthorizationFlow() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingPhotoSharing.ClearAuthorization)
function C_HousingPhotoSharing.ClearAuthorization() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingPhotoSharing.CompleteAuthorizationFlow)
---@param callbackURL string
function C_HousingPhotoSharing.CompleteAuthorizationFlow(callbackURL) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingPhotoSharing.GetCropRatio)
---@return number cropRatio
function C_HousingPhotoSharing.GetCropRatio() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingPhotoSharing.GetPhotoSharingAuthURL)
---@return string authUrl
function C_HousingPhotoSharing.GetPhotoSharingAuthURL() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingPhotoSharing.IsAuthorized)
---@return boolean authorized
function C_HousingPhotoSharing.IsAuthorized() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingPhotoSharing.IsEnabled)
---@return boolean enabled
function C_HousingPhotoSharing.IsEnabled() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingPhotoSharing.SetScreenshotPreviewTexture)
---@param textureObject SimpleTexture
function C_HousingPhotoSharing.SetScreenshotPreviewTexture(textureObject) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingPhotoSharing.TakePhoto)
function C_HousingPhotoSharing.TakePhoto() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_HousingPhotoSharing.UploadPhotoToService)
---@param optionalTitle? string Default = 
---@param optionalDescription? string Default = 
function C_HousingPhotoSharing.UploadPhotoToService(optionalTitle, optionalDescription) end
