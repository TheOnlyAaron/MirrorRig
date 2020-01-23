--*****************************************************
-- MirrorRig.ms
--
--Aaron Dabelow, theonlyaaron@gmail.com
-- www.aarondabelow.com
-- Written for MAX v.9.0 and up
--*****************************************************
-- PURPOSE:
--		Mirror Rigging
--*****************************************************
-- HISTORY:
--    - v1.0 (4.3.13):
--        (i) 1st version.
--*****************************************************

(
try(closeRolloutFloater mirrorRigRolloutFloater)catch()
)

ver = 1.0

-- Define search and replace pairs #( search , replace )
defaultSearchPairs = #(#("Left","Right"),#("Right","Left"),#("left","right"),#("right","left"),#("_L_","_R_"),#("_R_","_L_"),#("_l_","_r_"),#("_r_","_l_"))
customSearchPair = #()
global searchPairs

rollout mirrorRigRollout ("Mirror Rig " + (ver as string))
(
-- UI Elements
groupbox mirrorGroup "Mirroring" offset: [-10,-5] width:155 height:43
	button mirrorXButton "Mirror X" pos:[9,18] width:47 tooltip:"Flip your selection using world X axis."
	button mirrorYButton "Mirror Y" pos:[57,18] width:47  tooltip:"Flip your selection using world Y axis."
	button mirrorZButton "Mirror Z" pos:[105,18] width:47 tooltip:"Flip your selection using world Z axis."
groupbox duplicateGroup "Duplication" offset: [-10,5] width: 155 height:50
	checkBox makeCopy "Mirror as duplicate" pos:[9,65] checked:false 
	checkBox instanceCheck "Duplicate as instance" offset:[-4,-4] checked:false enabled:false
groupbox rigChecksGroup "Rig Checks" offset: [-10,0] width: 155 height:50
	checkBox flipLookatsCheck "Flip Lookat constraints" pos:[9,115] checked:true
	checkBox autoBreakCheck "Auto Breakout Selection" offset:[-4,-4] checked:false
groupbox renameGroup "Renaming" offset: [-10,5] width: 155 height:125
	checkbox autoRenameCheck "Auto: 'Left' <=> 'Right'" pos:[9,170] checked:true
	checkbox customRenameCheck "Custom rename" offset:[-4,-4] checked:false enabled:true
	edittext changeFromBox "" offset:[-8,-2] width:70 enabled:false
	edittext changeToBox "" offset:[70,-22] width:70 enabled:false
	label labChange "to" offset:[0,-20] enabled:false
	button previewRenamingButton "Preview renaming" height:20 width:145 alighn:#left
	multilistbox previewMultiList "" offset:[-5,-5] height:2 width:145 items:#("")
hyperLink aaronDabelow "© 2013  Aaron Dabelow" address:"http://aarondabelow.com/" tooltip:"www.aarondabelow.com" offset:[-5,5]
button informationButton "?" offset:[125,-22] width: 20 height:20  tooltip:"Information" align:#left


-- Functions
function setSearchPairs = -- sets the current search pairs based on ui choices
	(
	if autoRenameCheck.checked == true then(searchPairs = defaultSearchPairs)
	else(searchPairs = #(#(changeFromBox.text,changeToBox.text)))
	)

function renameObjectsFunction objArrArg searchPairsArg modeArg = -- objectsArr: the objects to rename	searchPairsArg: paired strings in array	modeArg: 1=preview 2=do
	(
	-- Clear and set variables
	searchPairs = searchPairsArg
	strArr=undefined
	failcount =0
	objArr = (selection as array)
		
	print objArr

	--Pass only if there are objects selected
	if objArr.count > 0 then
		(	
		-- Set the selected objects names to an array, and duplicate name array for processing
		strArr = #()
		for i in 1 to objArr.count do(join strArr #(objArr[i].name))
		newStrArr = deepcopy strArr
			
		-- Loop through and define the current search Pairs
		for j in 1 to searchPairs.count do
			(
			fromStr = searchPairs[j][1]
			toStr = searchPairs[j][2]
			
			-- Loop through the object array
			for i in 1 to strArr.count do
				(
				curStr = strArr[i]
				newStr = (substituteString curStr fromStr toStr) -- Test the search pairs
				if curStr != newStr then(newStrArr[i] = newStr)else(failCount = failcount+1) -- Add corrected pair to duplicate name array
				)
			)
			
		case modeArg of
			(
			1: (previewMultiList.items = newStrArr) -- Rename the objects with the duplicate array
			2: (for i in 1 to objArr.count do(objArr[i].name = newStrArr[i])) -- Rename the objects with the duplicate array
			default: Print "error"
			)
		)
	)

function duplicateEnableUIFunction bool =
	(
	if bool == true then (instanceCheck.enabled = true)else (instanceCheck.enabled = false)
	)

function renamingEnableUIFunction bool =
	(
	if bool == 1 then
		(
		if customRenameCheck.checked == true then
			(
			labChange.enabled = true
			changeFromBox.enabled = true
			changeToBox.enabled = true
			)
		else
			(
			labChange.enabled = false
			changeFromBox.enabled = false
			changeToBox.enabled = false
			)
		autoRenameCheck.checked = false
		)
	else
		(
		labChange.enabled = false
		changeFromBox.enabled = false
		changeToBox.enabled = false
		customRenameCheck.checked = false
		)
	)
	
function breakoutFunction objArrArg = -- Unparents any objects that are parented to objects outside of the selection
	(
	objArr = objArrArg
	subObjArr = #()
	preserveArr = #()

	for i in 1 to objArr.count do -- loop the objects
	(
	if objArr[i].parent != undefined then
		(
		join subObjArr #(objArr[i])
		)
	)

	for i in 1 to subObjArr.count do
		(
		preserveVar = false
		for j in 1 to objArr.count do
			(
			if subObjArr[i].parent == objArr[j] -- test to preserve
			then (preserveVar = true)
			)
		join preserveArr #(preserveVar)
		)	

	for i in 1 to subObjArr.count do
		(
		if preserveArr[i] == true then ()
		else(subObjArr[i].parent = undefined)
		)
	)
	
function flipLookatsFunction objArrArg = -- searches for any lookat constraints and flips them 
	(
	objArr = objArrArg
	
	for i in 1 to objArr.count do
		(
		try
			(
			if objArr[i].rotation.controller.LookAt_Constraint.controller.target_axisFlip == off then (lookatVal = 1)else()
			if objArr[i].rotation.controller.LookAt_Constraint.controller.target_axisFlip == on then (lookatVal = 2)else()
			if(lookatVal ==1)then(objArr[i].rotation.controller.LookAt_Constraint.controller.target_axisFlip = on)	else()
			if(lookatVal ==2)then(objArr[i].rotation.controller.LookAt_Constraint.controller.target_axisFlip = off)	else()
			)
		catch()
		)
	)
	
function informationFloaterFunction =
	(
	try(closerolloutfloater InformationDialog)catch()
	rollout InformationDialog "Mirror Rig info"
		(
		label labSpace1 "Mirror Rig version 1.0"
		hyperLink DTBLink "Mirror Rig Info" address:"http://www.aarondabelow.com/v1/pages/maxscript/maxscript-mirror_rig.html" align:#center
		hyperLink aaronDabelow "Aaron Dabelow" address:"http://aarondabelow.com/" align:#center
		label lab6 "theonlyaaron@gmail.com"
		label labSpace2 ""
		)
	createDialog InformationDialog 175 100
	)

-- Main Function 
function flipFunction objArrArg flipDirection =
	(
	objArr = objArrArg
		
	-- breaks out any parented objects if breakout enabled
	if autoBreakCheck.checked == true then (breakoutFunction objArr)
		
	-- makes a copy of the selection
	if makeCopy.checked == true
		then
		(
			if instanceCheck.checked == true
			then (maxOps.CloneNodes objArr cloneType:#instance)
			else (maxOps.CloneNodes objArr cloneType:#copy)
		)
		else()
		
	--rename the objects if enabled
	setSearchPairs()
	if autoRenameCheck.checked == true or customRenameCheck.checked == true then ( searchPairsBool = 2 ) else ( searchPairsBool = 1)
	renameObjectsFunction selection searchPairs searchPairsBool
	
	-- Actully do the FLIP!
	try(
	tempGroup = group selection name:"TempGroup"
	tempgroup.pivot = [0,0,0]
	scale tempgroup flipDirection
	ungroup tempGroup
	) catch (messagebox "Error: Not all of your selection is independent from outside objects, try enabling 'Auto Breakout' to automatically unparent any of these objects. WARNING! This will modify your hierarchy!")
	
	-- flips any lookat constraints if enabled
	if flipLookatsCheck.checked == true then (flipLookatsFunction objArr)

	clearUndoBuffer()
	)

-- event handlers
on mirrorXButton pressed do (try(flipFunction selection [-1,1,1])catch(messagebox "Unexpected Error."))
on mirrorYButton pressed do (try(flipFunction selection [1,-1,1])catch(messagebox "Unexpected Error."))
on mirrorZButton pressed do (try(flipFunction selection [1,1,-1])catch(messagebox "Unexpected Error."))
on makeCopy changed state do (duplicateEnableUIFunction state)
on autoRenameCheck changed state do (renamingEnableUIFunction 2)
on customRenameCheck changed state do (renamingEnableUIFunction 1)
on previewRenamingButton pressed do (setSearchPairs();renameObjectsFunction selection searchPairs 1)
on informationButton pressed do (informationFloaterFunction())
)

mirrorRigRolloutFloater = newrolloutfloater "Mirror Rig" 175 340
addrollout mirrorRigRollout mirrorRigRolloutFloater