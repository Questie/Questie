---@meta _
C_PhotoSharing = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PhotoSharing.BeginAuthorizationFlow)
function C_PhotoSharing.BeginAuthorizationFlow() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PhotoSharing.ClearAuthorization)
function C_PhotoSharing.ClearAuthorization() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PhotoSharing.CompleteAuthorizationFlow)
---@param callbackURL string
function C_PhotoSharing.CompleteAuthorizationFlow(callbackURL) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PhotoSharing.GetCropRatio)
---@return number cropRatio
function C_PhotoSharing.GetCropRatio() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PhotoSharing.GetPhotoSharingAuthURL)
---@return string authUrl
function C_PhotoSharing.GetPhotoSharingAuthURL() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PhotoSharing.GetStatus)
---@return Enum.PhotoSharingStatus status
function C_PhotoSharing.GetStatus() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PhotoSharing.IsAuthorized)
---@return boolean authorized
function C_PhotoSharing.IsAuthorized() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PhotoSharing.IsEnabled)
---@return boolean enabled
function C_PhotoSharing.IsEnabled() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PhotoSharing.SetScreenshotPreviewTexture)
---@param textureObject SimpleTexture
function C_PhotoSharing.SetScreenshotPreviewTexture(textureObject) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PhotoSharing.TakePhoto)
function C_PhotoSharing.TakePhoto() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PhotoSharing.UploadPhotoToService)
---@param optionalTitle? string Default = 
---@param optionalDescription? string Default = 
function C_PhotoSharing.UploadPhotoToService(optionalTitle, optionalDescription) end
