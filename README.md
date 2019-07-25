# UnitFramesImproved_TBCFixedFocus
UnitFramesImproved_TBC from k0oz with Fixed Focus Frame. All credit goes to k0oz for backporting this to TBC
https://github.com/Ko0z/UnitFramesImproved_TBC is the repository for the original AddOn. 

### Before
<img src=images/UFI_TBC_BEFORE1.png width=700>
### After
<img src=images/UFI_TBC_AFTER.png width=700>
### Dependancies 
For this to work it requires you use _**either**_ FocusFrame _**or**_ ExtendedUF to create your focus frames in TBC. Will not work with any others.
You can try adding whatever focus frame addon you're using into `## OptionalDeps: ExtendedUF, FocusFrame` line 8 of the `UnitFramesImproved_TBC.toc` file and pray to god your focusframe addon creates a focus frame in the same way ExtendedUF and FocusFrame do. 
### How to Install
place UnitFramesImproved_TBC folder into your AddOns folder.


### Changelog 

Added a lot of lines of .lua to make the stylize method affect Focus Frame
Added ExtendedUF and FocusFrame as Optional Dependancies of UnitFramesImproved_TBC so either ExtendedUF or FocusFrame loads before blackframe does and it doesn't try to stylize/change texture of frames that aren't made yet :)
