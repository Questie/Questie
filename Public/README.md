# Questie API

The files in this directory provide an API for interacting with Questie. Everything that is exposed via `Questie.API` should be considered stable and safe to use.

## How to use it

To use the Questie API, you first need to ensure that Questie is loaded, e.g. by using the `IsAddOnLoaded` API.

Afterward you need to wait for Questie to be fully initialized. Once `Questie.API.isReady` is true, you can be sure the APIs return valid data. If you don't want to poll for it,
you can register a callback via `Questie.API.RegisterOnReady`, which will be called once Questie is ready.

For details on the individual API functions, please check the other files in this directory or hit us up [on Discord](https://discord.gg/s33MAYKeZd)!