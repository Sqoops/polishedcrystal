
; Trade struct
TRADE_DIALOG  EQU 0
TRADE_GIVEMON EQU 1
TRADE_GETMON  EQU 2
TRADE_NICK    EQU 3
TRADE_DVS     EQU 14
TRADE_ITEM    EQU 16
TRADE_OT_ID   EQU 17
TRADE_OT_NAME EQU 19
TRADE_GENDER  EQU 30
TRADE_PADDING EQU 31

; Trade dialogs
TRADE_INTRO    EQU 0
TRADE_CANCEL   EQU 1
TRADE_WRONG    EQU 2
TRADE_COMPLETE EQU 3
TRADE_AFTER    EQU 4

NPCTrade:: ; fcba8
	ld a, e
	ld [wJumptableIndex], a
	call Functionfcc59
	ld b, CHECK_FLAG
	call TradeFlagAction
	ld a, TRADE_AFTER
	jr nz, .done

	ld a, TRADE_INTRO
	call PrintTradeText

	call YesNoBox
	ld a, TRADE_CANCEL
	jr c, .done

; Select givemon from party
	ld b, 6
	callba Function5001d
	ld a, TRADE_CANCEL
	jr c, .done

	ld e, TRADE_GIVEMON
	call GetTradeAttribute
	ld a, [CurPartySpecies]
	cp [hl]
	ld a, TRADE_WRONG
	jr nz, .done

	call CheckTradeGender
	ld a, TRADE_WRONG
	jr c, .done

	ld b, SET_FLAG
	call TradeFlagAction

	ld hl, ConnectLinkCableText
	call PrintText

	call Functionfcc63
	call Functionfcc07
	call GetTradeMonNames

	ld hl, TradedForText
	call PrintText

	call RestartMapMusic

	ld a, TRADE_COMPLETE

.done
	call PrintTradeText
	ret
; fcc07

Functionfcc07: ; fcc07
	call DisableSpriteUpdates
	ld a, [wJumptableIndex]
	push af
	ld a, [wcf64]
	push af
	predef Function28f24
	pop af
	ld [wcf64], a
	pop af
	ld [wJumptableIndex], a
	call Function2b74
	ret
; fcc23

CheckTradeGender: ; fcc23
	xor a
	ld [MonType], a

	ld e, TRADE_GENDER
	call GetTradeAttribute
	ld a, [hl]
	and a
	jr z, .asm_fcc46
	cp 1
	jr z, .asm_fcc3e

	callba GetGender
	jr nz, .asm_fcc48
	jr .asm_fcc46

.asm_fcc3e
	callba GetGender
	jr z, .asm_fcc48

.asm_fcc46
	and a
	ret

.asm_fcc48
	scf
	ret
; fcc4a

TradeFlagAction: ; fcc4a
	ld hl, wd960
	ld a, [wJumptableIndex]
	ld c, a
	predef FlagPredef
	ld a, c
	and a
	ret
; fcc59

Functionfcc59: ; fcc59
	ld e, TRADE_DIALOG
	call GetTradeAttribute
	ld a, [hl]
	ld [wcf64], a
	ret
; fcc63

Functionfcc63: ; fcc63
	ld e, TRADE_GIVEMON
	call GetTradeAttribute
	ld a, [hl]
	ld [wc6d0], a

	ld e, TRADE_GETMON
	call GetTradeAttribute
	ld a, [hl]
	ld [wc702], a

	ld a, [wc6d0]
	ld de, wc6d1
	call Functionfcde8
	call Functionfcdf4

	ld a, [wc702]
	ld de, wc703
	call Functionfcde8
	call Functionfcdf4

	ld hl, PartyMonOT
	ld bc, NAME_LENGTH
	call Functionfcdd7
	ld de, wc6f2
	call Functionfcdf4

	ld hl, PlayerName
	ld de, wc6e7
	call Functionfcdf4

	ld hl, PartyMon1ID
	ld bc, PARTYMON_STRUCT_LENGTH
	call Functionfcdd7
	ld de, wc6ff
	call Functionfce0f

	ld hl, PartyMon1DVs
	ld bc, PARTYMON_STRUCT_LENGTH
	call Functionfcdd7
	ld de, wc6fd
	call Functionfce0f

	ld hl, PartyMon1Species
	ld bc, PARTYMON_STRUCT_LENGTH
	call Functionfcdd7
	ld b, h
	ld c, l
	callba GetCaughtGender
	ld a, c
	ld [wc701], a

	ld e, TRADE_DIALOG
	call GetTradeAttribute
	ld a, [hl]
	cp TRADE_COMPLETE
	ld a, 1
	jr c, .asm_fcce6
	ld a, 2
.asm_fcce6
	ld [wEnemyCharging], a

	ld hl, PartyMon1Level
	ld bc, PARTYMON_STRUCT_LENGTH
	call Functionfcdd7
	ld a, [hl]
	ld [CurPartyLevel], a
	ld a, [wc702]
	ld [CurPartySpecies], a
	xor a
	ld [MonType], a
	ld [wPokemonWithdrawDepositParameter], a
	callab Functione039
	predef TryAddMonToParty

	ld e, TRADE_DIALOG
	call GetTradeAttribute
	ld a, [hl]
	cp TRADE_COMPLETE
	ld b, 0
	jr c, .asm_fcd1c
	ld b, 1
.asm_fcd1c
	callba SetGiftPartyMonCaughtData

	ld e, TRADE_NICK
	call GetTradeAttribute
	ld de, wc70e
	call Functionfcdf4

	ld hl, PartyMonNicknames
	ld bc, PKMN_NAME_LENGTH
	call Functionfcdde
	ld hl, wc70e
	call Functionfcdf4

	ld e, TRADE_OT_NAME
	call GetTradeAttribute
	push hl
	ld de, wc724
	call Functionfcdf4
	pop hl
	ld de, wc719
	call Functionfcdf4

	ld hl, PartyMonOT
	ld bc, NAME_LENGTH
	call Functionfcdde
	ld hl, wc724
	call Functionfcdf4

	ld e, TRADE_DVS
	call GetTradeAttribute
	ld de, wEnemyTrappingMove
	call Functionfce0f

	ld hl, PartyMon1DVs
	ld bc, PARTYMON_STRUCT_LENGTH
	call Functionfcdde
	ld hl, wEnemyTrappingMove
	call Functionfce0f

	ld e, TRADE_OT_ID
	call GetTradeAttribute
	ld de, wPlayerCharging
	call Functionfce15

	ld hl, PartyMon1ID
	ld bc, PARTYMON_STRUCT_LENGTH
	call Functionfcdde
	ld hl, wEnemyWrapCount
	call Functionfce0f

	ld e, TRADE_ITEM
	call GetTradeAttribute
	push hl
	ld hl, PartyMon1Item
	ld bc, PARTYMON_STRUCT_LENGTH
	call Functionfcdde
	pop hl
	ld a, [hl]
	ld [de], a

	push af
	push bc
	push de
	push hl
	ld a, [CurPartyMon]
	push af
	ld a, [PartyCount]
	dec a
	ld [CurPartyMon], a
	callba Functione134
	pop af
	ld [CurPartyMon], a
	pop hl
	pop de
	pop bc
	pop af
	ret
; fcdc2


GetTradeAttribute: ; 0xfcdc2
	ld d, 0
	push de
	ld a, [wJumptableIndex]
	and $f
	swap a
	ld e, a
	ld d, 0
	ld hl, NPCTrades
rept 2
	add hl, de
endr
	pop de
	add hl, de
	ret
; 0xfcdd7

Functionfcdd7: ; fcdd7
	ld a, [CurPartyMon]
	call AddNTimes
	ret
; fcdde

Functionfcdde: ; fcdde
	ld a, [PartyCount]
	dec a
	call AddNTimes
	ld e, l
	ld d, h
	ret
; fcde8

Functionfcde8: ; fcde8
	push de
	ld [wd265], a
	call GetBasePokemonName
	ld hl, StringBuffer1
	pop de
	ret
; fcdf4

Functionfcdf4: ; fcdf4
	ld bc, NAME_LENGTH
	call CopyBytes
	ret
; fcdfb

Functionfcdfb: ; fcdfb
	ld bc, 4
	call CopyBytes
	ld a, $50
	ld [de], a
	ret
; fce05

Functionfce05: ; fce05
	ld bc, 3
	call CopyBytes
	ld a, $50
	ld [de], a
	ret
; fce0f

Functionfce0f: ; fce0f
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hl]
	ld [de], a
	ret
; fce15

Functionfce15: ; fce15
	ld a, [hli]
	ld [de], a
	dec de
	ld a, [hl]
	ld [de], a
	ret
; fce1b

GetTradeMonNames: ; fce1b
	ld e, TRADE_GETMON
	call GetTradeAttribute
	ld a, [hl]
	call Functionfcde8

	ld de, StringBuffer2
	call Functionfcdf4

	ld e, TRADE_GIVEMON
	call GetTradeAttribute
	ld a, [hl]
	call Functionfcde8

	ld de, wd050
	call Functionfcdf4

	ld hl, StringBuffer1
.loop
	ld a, [hli]
	cp "@"
	jr nz, .loop

	dec hl
	push hl
	ld e, TRADE_GENDER
	call GetTradeAttribute
	ld a, [hl]
	pop hl
	and a
	ret z

	cp 1
	ld a, "♂"
	jr z, .done
	ld a, "♀"
.done
	ld [hli], a
	ld [hl], "@"
	ret
; fce58


NPCTrades: ; fce58
	db 0, ABRA,       MACHOP,     "MUSCLE@@@@@", $37, $66, GOLD_BERRY,   $54, $92, "MIKE@@@@@@@", 0, 0
	db 0, BELLSPROUT, ONIX,       "ROCKY@@@@@@", $96, $66, BITTER_BERRY, $1e, $bf, "KYLE@@@@@@@", 0, 0
	db 1, KRABBY,     VOLTORB,    "VOLTY@@@@@@", $98, $88, PRZCUREBERRY, $05, $72, "TIM@@@@@@@@", 0, 0
	db 3, DRAGONAIR,  DODRIO,     "DORIS@@@@@@", $77, $66, SMOKE_BALL,   $1b, $01, "EMY@@@@@@@@", 2, 0
	db 2, HAUNTER,    XATU,       "PAUL@@@@@@@", $96, $86, MYSTERYBERRY, $00, $3d, "CHRIS@@@@@@", 0, 0
	db 3, CHANSEY,    AERODACTYL, "AEROY@@@@@@", $96, $66, GOLD_BERRY,   $7b, $67, "KIM@@@@@@@@", 0, 0
	db 0, DUGTRIO,    MAGNETON,   "MAGGIE@@@@@", $96, $66, METAL_COAT,   $a2, $c3, "FOREST@@@@@", 0, 0
; fcf38


PrintTradeText: ; fcf38
	push af
	call GetTradeMonNames
	pop af
	ld bc, 2 * 4
	ld hl, TradeTexts
	call AddNTimes
	ld a, [wcf64]
	ld c, a
rept 2
	add hl, bc
endr
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call PrintText
	ret
; fcf53

TradeTexts: ; fcf53
; intro
	dw TradeIntroText1
	dw TradeIntroText2
	dw TradeIntroText3
	dw TradeIntroText4

; cancel
	dw TradeCancelText1
	dw TradeCancelText2
	dw TradeCancelText3
	dw TradeCancelText4

; wrong mon
	dw TradeWrongText1
	dw TradeWrongText2
	dw TradeWrongText3
	dw TradeWrongText4

; completed
	dw TradeCompleteText1
	dw TradeCompleteText2
	dw TradeCompleteText3
	dw TradeCompleteText4

; after
	dw TradeAfterText1
	dw TradeAfterText2
	dw TradeAfterText3
	dw TradeAfterText4
; fcf7b


ConnectLinkCableText: ; 0xfcf7b
	; OK, connect the Game Link Cable.
	text_jump UnknownText_0x1bd407
	db "@"
; 0xfcf80


TradedForText: ; 0xfcf80
	; traded givemon for getmon
	text_jump UnknownText_0x1bd429
	start_asm

	ld de, MUSIC_NONE
	call PlayMusic
	call DelayFrame
	ld hl, .done
	ret

.done
	; sound0x0A
	; interpret_data
	text_jump UnknownText_0x1bd445
	db "@"
; 0xfcf97


TradeIntroText1: ; 0xfcf97
	; I collect #MON. Do you have @ ? Want to trade it for my @ ?
	text_jump UnknownText_0x1bd449
	db "@"
; 0xfcf9c

TradeCancelText1: ; 0xfcf9c
	; You don't want to trade? Aww…
	text_jump UnknownText_0x1bd48c
	db "@"
; 0xfcfa1

TradeWrongText1: ; 0xfcfa1
	; Huh? That's not @ .  What a letdown…
	text_jump UnknownText_0x1bd4aa
	db "@"
; 0xfcfa6

TradeCompleteText1: ; 0xfcfa6
	; Yay! I got myself @ ! Thanks!
	text_jump UnknownText_0x1bd4d2
	db "@"
; 0xfcfab

TradeAfterText1: ; 0xfcfab
	; Hi, how's my old @  doing?
	text_jump UnknownText_0x1bd4f4
	db "@"
; 0xfcfb0


TradeIntroText2:
TradeIntroText3: ; 0xfcfb0
	; Hi, I'm looking for this #MON. If you have @ , would you trade it for my @ ?
	text_jump UnknownText_0x1bd512
	db "@"
; 0xfcfb5

TradeCancelText2:
TradeCancelText3: ; 0xfcfb5
	; You don't have one either? Gee, that's really disappointing…
	text_jump UnknownText_0x1bd565
	db "@"
; 0xfcfba

TradeWrongText2:
TradeWrongText3: ; 0xfcfba
	; You don't have @ ? That's too bad, then.
	text_jump UnknownText_0x1bd5a1
	db "@"
; 0xfcfbf

TradeCompleteText2: ; 0xfcfbf
	; Great! Thank you! I finally got @ .
	text_jump UnknownText_0x1bd5cc
	db "@"
; 0xfcfc4

TradeAfterText2: ; 0xfcfc4
	; Hi! The @ you traded me is doing great!
	text_jump UnknownText_0x1bd5f4
	db "@"
; 0xfcfc9


TradeIntroText4: ; 0xfcfc9
	; 's cute, but I don't have it. Do you have @ ? Want to trade it for my @ ?
	text_jump UnknownText_0x1bd621
	db "@"
; 0xfcfce

TradeCancelText4: ; 0xfcfce
	; You don't want to trade? Oh, darn…
	text_jump UnknownText_0x1bd673
	db "@"
; 0xfcfd3

TradeWrongText4: ; 0xfcfd3
	; That's not @ . Please trade with me if you get one.
	text_jump UnknownText_0x1bd696
	db "@"
; 0xfcfd8

TradeCompleteText4: ; 0xfcfd8
	; Wow! Thank you! I always wanted @ !
	text_jump UnknownText_0x1bd6cd
	db "@"
; 0xfcfdd

TradeAfterText4: ; 0xfcfdd
	; How is that @  I traded you doing? Your @ 's so cute!
	text_jump UnknownText_0x1bd6f5
	db "@"
; 0xfcfe2


TradeCompleteText3: ; 0xfcfe2
	; Uh? What happened?
	text_jump UnknownText_0x1bd731
	db "@"
; 0xfcfe7

TradeAfterText3: ; 0xfcfe7
	; Trading is so odd… I still have a lot to learn about it.
	text_jump UnknownText_0x1bd745
	db "@"
; 0xfcfec
