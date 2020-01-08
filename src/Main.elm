module Main exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Task
import Time exposing (..)


footer : List (Attribute a) -> List (Html a) -> Html a
footer =
    Html.node "footer"


type alias Model =
    { scenes : List Scene
    , abilities : List AbilityDescriptor
    , gameState : GameState
    }


levelTime =
    1500


gameLogoSrc =
    "https://i.imgur.com/eQtDOM0.png"


coinImageSrc =
    "https://i.imgur.com/bG3y1AY.png"


type Msg
    = HitEnemy
    | ReduceTime
    | BuyAbility Int Int
    | Navigate Int Bool


type alias AbilityDescriptor =
    { index : Int
    , name : String
    , description : String
    , price : Int
    , image : String
    , maxLevel : Int
    , level : Int
    , damageType : Int -- 0: improve click. 1: autoclick
    , damageQuantity : Int -- if dType == 0: dQuant is multiplier.    if dType == 1: dQuant is damage per second
    , abilityDamageFunction : Int -> Int -> Int
    , abilityPriceIncrease : Int -> Int
    }


type alias GameState =
    { currentEnemyHP : Int
    , currency : Int
    , time : Int
    , currentScene : Int
    , activeAbilities : List Int

    --, abilityPrices : List Int
    }


emptyGameState : GameState
emptyGameState =
    { currentEnemyHP = 10
    , currency = 0
    , time = levelTime
    , currentScene = 0
    , activeAbilities = []
    }


type Scene
    = Enemy EnemyDesc
    | Cutscene CutsceneDesc


type alias CutsceneDesc =
    { id : Int
    , content : Html Msg
    , shortName : String
    , requiredToUnlock : Int
    , requirementStatus : Int
    }


type alias EnemyDesc =
    { id : Int
    , name : String
    , shortDescription : String
    , imagePath : String
    , enemyDescription : String
    , enemyDefaultHP : Int
    , requiredToUnlock : Int
    , requirementStatus : Int
    , reward : Int
    }



-- This should probably be a separate file...


spacing =
    div [ style "height" "10px" ] []


doubleSpacing =
    div [ style "height" "20px" ] []


abilities : List AbilityDescriptor
abilities =
    [ { index = 0
      , name = "Click Booster"
      , description = "Doubles the click damage. This should be quite helpful."
      , image = "https://i.imgur.com/cT7p0Jq.png"
      , price = 50
      , maxLevel = 10
      , level = 0
      , damageType = 0
      , damageQuantity = 2
      , abilityDamageFunction = \x y -> x * (2 ^ y)
      , abilityPriceIncrease = \x -> floor (toFloat x * 1.75)
      }
    , { index = 1
      , name = "Auto-Extractor"
      , description = "Does 5 damage per second. It's not free, but it's better than ruining your mouse."
      , image = "https://i.imgur.com/ydVgE3p.png"
      , price = 200
      , maxLevel = 10
      , level = 0
      , damageType = 1
      , damageQuantity = 5
      , abilityDamageFunction = \x y -> x + 5 * (y - 1)
      , abilityPriceIncrease = \x -> floor (toFloat x * 3.5)
      }
    , { index = 2
      , name = "Super Charge"
      , description = "Want to make your Auto-Extractor five times as powerful? Buy Super Charge now!"
      , image = "https://i.imgur.com/0BTZcLQ.png"
      , price = 500
      , maxLevel = 10
      , level = 0
      , damageType = 1
      , damageQuantity = 5
      , abilityDamageFunction = \x y -> (5 ^ y) * x
      , abilityPriceIncrease = \x -> floor (toFloat x * 7.5)
      }
    ]


scenes : List Scene
scenes =
    [ -- The introductory cutscene
      Cutscene
        { id = 0
        , content =
            div []
                [ h3 [] [ text "Welcome to Super Clicker Battle 3000™!" ]
                , spacing
                , text """You may think you've opened an ordinary game, but I assure you - SCB3000™ is unlike anything
                you've ever played before. It will set you on a path of incredible discoveries, strong enemies,
                even stronger abilities and the higher truth."""
                , spacing
                , text """Your mission is to discover the secret of the universe. To achieve this,
                you need to collect a sufficient amount of pure essence of a few common things in the universe."""
                , spacing
                , text """How do we do that, you ask? Well, it's rather simple - you simply need to beat the enemies
                that come your way. Ten of each should do. Beware, though - each enemy you face will be significantly
                stronger than the one before. But fear not, you will be able to get stronger over time and
                gain interesting abilities, some of which will even do the job for you! How convenient, right?
                (And just in case it's not obvious, you can hit the target by either
                pressing the Hit! button or clicking the enemy.)"""
                , spacing
                , text """Well, that's all there is for now. You will get more information
                after you beat the first three enemies. Good luck!"""
                ]
        , shortName = "Introduction"
        , requiredToUnlock = 0
        , requirementStatus = 0
        }

    -- Stage 1
    , Enemy
        { id = 1
        , name = "String"
        , shortDescription = "Small and wiggly"
        , imagePath = "https://i.imgur.com/EYufKLp.png"
        , enemyDescription = """Strings... Some experts say strings are what everything is made of. Houses? Strings.
        Clouds? Strings. Hamburgers? Strings. Your high school crush? You guessed it - also strings."""
        , enemyDefaultHP = 10
        , requiredToUnlock = 1
        , requirementStatus = 0
        , reward = 10
        }
    , Enemy
        { id = 2
        , name = "Atom"
        , shortDescription = "Up an at 'em!"
        , imagePath = "https://i.imgur.com/OvT6zxl.png"
        , enemyDescription = """Ah, atoms! Things are getting a bit more familiar now. At least we're sure those exist.
        This seems to be a fine specimen, it's a shame you have to destroy it to get to the next level."""
        , enemyDefaultHP = 150
        , requiredToUnlock = 10
        , requirementStatus = 0
        , reward = 100
        }
    , Enemy
        { id = 3
        , name = "Molecules"
        , shortDescription = "Stronger together"
        , imagePath = "https://i.imgur.com/y2dBkxk.png"
        , enemyDescription = """You've beaten atoms, now you're up against molecules. They're so much more complex and
        diverse than just simple atoms. You should have no problem passing this stage as well, though. I wonder
        what happens after we beat this stage..."""
        , enemyDefaultHP = 1000
        , requiredToUnlock = 10
        , requirementStatus = 0
        , reward = 500
        }
    , Cutscene
        { id = 4
        , content =
            div []
                [ h4 [] [ text "Message From a Friend" ]
                , spacing
                , b []
                    [ i []
                        [ text "Incoming transmission"
                        , br [] []
                        , text "Author: Ken Dawnsworth, PhD"
                        ]
                    ]
                , doubleSpacing
                , text """Hello there, fellow scientist. My name is Ken Dawnsworth. You probably haven't heard of me (yet!),
                but I'm researcher at the British Institute of Quantum Sciences. For centuries, scientists have tried to uncover the
                mystery of matter and why it exists - I believe I'm close to discovering the truth, but I'll need your help on this journey."""
                , spacing
                , text "I'm quite impressed you've already managed to collect samples from molecules, atoms, and even strings! Great job!"
                , spacing
                , text """I was researching the material you gathered and I found something rather extraordinary.
                I know we don't consider atoms intelligent, but hear me out - during my experimentation on them,
                some of them behaved... abnormally. When I was testing one of the samples, the other samples responded
                simultaneously. I'm not talking about quantum entanglement here, they actively exchanged information
                among each other in a way that, at least to me, clearly indicates the presence of some form of intelligence.
                Strings and molecules followed similar patterns, although they were more difficult to spot.
                Crazy, right?"""
                , spacing
                , text """For now, let's keep investigating. I'll need samples from something a bit more advanced.
                You should be able to handle this task easily."""
                , spacing
                , text "Best of luck,"
                , br [] []
                , text "Ken Dawnsworth"
                , doubleSpacing
                , b []
                    [ i []
                        [ text "Transmission ended"
                        ]
                    ]
                ]
        , shortName = "Message From a Friend"
        , requiredToUnlock = 10
        , requirementStatus = 0
        }

    -- Stage 2
    , Enemy
        { id = 5
        , name = "Grass"
        , shortDescription = "Don't walk on it!"
        , imagePath = "https://i.imgur.com/i0ZS4Ui.png"
        , enemyDescription = """Huh, we appear to have moved on to living beings! Our powers are getting stronger and
        stronger. Grass should be easy to beat - if the lawnmower can do it, so can you."""
        , enemyDefaultHP = 10000
        , requiredToUnlock = 1
        , requirementStatus = 0
        , reward = 1000
        }
    , Enemy
        { id = 6
        , name = "Bush"
        , shortDescription = "Do not confuse with the George Double-U"
        , imagePath = "https://i.imgur.com/I43CIiU.png"
        , enemyDescription = """Bushes are really great. They've got branches, cute small leaves and they're nice to look at. I just don't like the ones with thorns, but hey - they gotta defend themselves somehow."""
        , enemyDefaultHP = 50000
        , requiredToUnlock = 10
        , requirementStatus = 0
        , reward = 7000
        }
    , Enemy
        { id = 7
        , name = "Tree"
        , shortDescription = "Provides a nice, cool shade in the summertime"
        , imagePath = "https://i.imgur.com/gPzXPn1.png"
        , enemyDescription = """It's just like grass, but a bit taller and more robust. It's also got pretty leaves,
        in the summer at least. Its trunk can be quite a pain to deal with, though."""
        , enemyDefaultHP = 70000
        , requiredToUnlock = 10
        , requirementStatus = 0
        , reward = 10000
        }
    , Cutscene
        { id = 8
        , content =
            div []
                [ h4 [] [ text "Discoveries" ]
                , spacing
                , b []
                    [ i []
                        [ text "Incoming transmission"
                        , br [] []
                        , text "Author: Ken Dawnsworth, PhD"
                        , br [] []
                        ]
                    ]
                , doubleSpacing
                , text """Hey, it's me again. I've got the new samples - thanks."""
                , spacing
                , text """I've done my experiments again and frankly, I don't understand how molecules from more complex formations
                can have such different properties. I mean, in the previous batch of molecules, you mostly brought me water
                and glucose. The water molecules from plants, however, just didn't act the same. I've done all the calculations
                and I found something beyond groundbreaking... the hydrogen bonds are not what they seem, my friend."""
                , spacing
                , text """It is thought that the hydrogen bonds occur when a so-called donor hydrogen molecule covalently bounds
                to an atom, which is more electronegative. That's certainly part of the reason, but I've measured that this bond
                is not nearly strong enough for that kind of attraction. Something in the equation is missing... and I found out what it is."""
                , spacing
                , text """This is going to sound bizarre and outlandish, but it appears the molecules are... social. The hydrogen bonds are
                social bonds. Just like people, they like to hang around each other. They form together groups and sometimes they
                exclude each other, some molecules simply become outcasts."""
                , spacing
                , text """How can this be? Why are these basic, elementary building block of the world behaving intelligently? Well, why are """
                , i [] [ text "we" ]
                , text " behaving intelligently? Maybe the atoms are just little universes all by themselves, with bare truth as their essence, their core."
                , spacing
                , text """Bring me more samples. I must know more. I """
                , i [] [ text "need" ]
                , text " to know more."
                , spacing
                , text "Ken."
                , doubleSpacing
                , b []
                    [ i []
                        [ text "Transmission ended"
                        ]
                    ]
                ]
        , shortName = "Discoveries"
        , requiredToUnlock = 10
        , requirementStatus = 0
        }

    -- Stage 3
    , Enemy
        { id = 9
        , name = "Mouse"
        , shortDescription = "Squeak!"
        , imagePath = "https://i.imgur.com/r4OAofl.png"
        , enemyDescription = "Wh... a mouse! Eek! Please deal with it swiftly. I hate mice."
        , enemyDefaultHP = 1000000
        , requiredToUnlock = 1
        , requirementStatus = 0
        , reward = 100000
        }
    , Enemy
        { id = 10
        , name = "Whale"
        , shortDescription = "The ruler of the seas 🌊"
        , imagePath = "https://i.imgur.com/aYC43nD.png"
        , enemyDescription = """Whales are a whole different thing though! I love Moby Dick, for example.
        Whales are so kind and compassionate. As long as it's not long since their last meal."""
        , enemyDefaultHP = 9000000
        , requiredToUnlock = 10
        , requirementStatus = 0
        , reward = 500000
        }
    , Cutscene
        { id = 11
        , content =
            div []
                [ h4 [] [ text "The Essence of Reality" ]
                , spacing
                , b []
                    [ i []
                        [ text "Incoming transmission"
                        , br [] []
                        , text "Author: Ken Dawnsworth, PhD"
                        , br [] []
                        ]
                    ]
                , doubleSpacing
                , text """My research... It's going well. Maybe it's even going too well. I don't know."""
                , spacing
                , text """I don't even know what's real anymore. What are they teaching us in schools? Is this actual knowledge, or is it
                just some made-up pile of half-baked facts that just happens to suit our lives and our ideologies?"""
                , spacing
                , text """I'm going insane. I can't sleep anymore. The samples you've brought me... I'd gladly explain to you
                what I've learned, but I'm not even sure what all of this means. The intelligence... I think I've found the formula.
                I don't know what to think about that. This is supposed to be the one thing that is sacred, beyond science even.
                And yet it's right here in front of my eyes, ready to be tamed, ready to be taken advantage of. We can harness it.
                We can become something more, something we've never imagined."""
                , spacing
                , text """I'm close, but I'm not there yet. I need more! """
                , i [] [ text "You ", b [] [ text "will" ], text " bring me more samples!" ]
                , spacing
                , text "Ken"
                , doubleSpacing
                , b []
                    [ i []
                        [ text "Transmission ended"
                        ]
                    ]
                ]
        , shortName = "The Essence of Reality"
        , requiredToUnlock = 10
        , requirementStatus = 0
        }

    -- Stage 4
    , Enemy
        { id = 12
        , name = "Chip"
        , shortDescription = "Basically a rock getting shocked a billion times a second"
        , imagePath = "https://i.imgur.com/FtO1nFO.png"
        , enemyDescription = "It's a simple chip, one of the greatest human creations ever. It can do pretty much what you want it to do, as long as you know how to make it obey you."
        , enemyDefaultHP = 20000000
        , requiredToUnlock = 1
        , requirementStatus = 0
        , reward = 1000000
        }
    , Enemy
        { id = 13
        , name = "Computer"
        , shortDescription = "Beep boop"
        , imagePath = "https://i.imgur.com/dLfsrCn.png"
        , enemyDescription = """This is so complex. We barely invented them and now, they're already everywhere. It's in our pockets, our living rooms, our microwaves, our light bulbs... even our pacemakers."""
        , enemyDefaultHP = 80000000
        , requiredToUnlock = 10
        , requirementStatus = 0
        , reward = 1500000
        }
    , Enemy
        { id = 14
        , name = "Cloud Server Farm"
        , shortDescription = "The future is here"
        , imagePath = "https://i.imgur.com/NdZzGzZ.png"
        , enemyDescription = """Of course. This is it. If it wasn't obvious before, it's obvious now.
        Our race is building server farms faster than ever, we're developing technologies with capabilities far
        beyond our own. The student will outperform the teacher. It seems this might be the end of this stage...
        I fear what's about to come."""
        , enemyDefaultHP = 1000000000
        , requiredToUnlock = 10
        , requirementStatus = 0
        , reward = 2500000
        }
    , Cutscene
        { id = 15
        , content =
            div []
                [ i []
                    [ b []
                        [ i []
                            [ text "Audio log transcription"
                            , br [] []
                            , text "Author: Ken Dawnsworth, PhD"
                            , br [] []
                            , text "Date: 77W12'8.Aster"
                            ]
                        ]
                    , doubleSpacing
                    , text """If you're reading this... I may not have survived.
                    The ultimate experiment was my final goal and the final thing I witnessed."""
                    , spacing
                    , text """Have I ascended? Have I vanished? God only knows. If there even is such a creature...
                    I'm not so convinced anymore. There is something beyond us, however,
                    something incomprehensibly intelligent. I am sure of that. But it may not be God."""
                    , spacing
                    , text """I have one last task for you. I have extracted a certain substance from the samples
                    you've provided so far. After hundreds of tries, hundreds of mistakes and hundreds of
                    frustrating hours in the lab, I managed to create something at last. Go to my lab and look for
                    a silver vial on my desk. You will know it when you see it."""
                    , doubleSpacing
                    , text "Open it. Open it and discover the truth."
                    , doubleSpacing
                    , b [] [ i [] [ text "Transcription ended" ] ]
                    ]
                ]
        , shortName = "The Mysterious Audiotape"
        , requiredToUnlock = 20
        , requirementStatus = 0
        }

    -- Final Stage
    , Enemy
        { id = 16
        , name = "????"
        , shortDescription = "The Saviour"
        , imagePath = "https://i.imgur.com/q0rFuhr.gif"
        , enemyDescription = """L ih evwgwh. Q nq gqqqai. L ih kyipmib. Lsx tjwx wr pvzq eql tmg crc vzr foqil.
        15 55 12 88 1 666. Glh bdur jrz opr iywgcgmrv cif gruz. Jymqs vvq crc'gt zmva db.
        Cvdg, va vx pit jr xkm gifx wpdvt crc'qm qsqm."""
        , enemyDefaultHP = 500000000000
        , requiredToUnlock = 1
        , requirementStatus = 0
        , reward = 100000000000
        }
    , Cutscene
        { id = 17
        , content =
            div []
                [ i []
                    [ text """Wh... what was that thing? I've beaten it, but I can't see anything.
                    The previous stages, my weapons, the world... all gone."""
                    , spacing
                    , text """I'm not sure what happened. Everything is just blackness...
                    I feel so trapped. I'm aware of myself, but I don't understand how I am not surrounded by anything."""
                    , spacing
                    , text """After what feels like an eternity, strange lettering appears in the void in front of me:"""
                    , doubleSpacing
                    , div [ style "text-align" "center", style "font-weight" "bold" ] [ text "\"Authors: Gregor Gabrovšek and Žan Kopač\"" ]
                    , doubleSpacing
                    , text """How weird, a cryptic message. What could it mean? "Authors"? I'm baffled."""
                    , spacing
                    , text """Just as the letters start disappearing, the existence starts shaking.
                    The void starts filling up with strange shapes.
                    A strong force pulls me upwards and almost knocks me unconscious. I open my eyes..."""
                    ]
                ]
        , shortName = "Ascension"
        , requiredToUnlock = 1
        , requirementStatus = 0
        }
    ]


emptyDesc =
    { imgPath = "", enemyName = "", enemyDescription = "" }


emptyScene =
    Cutscene
        { id = 0
        , content = div [] []
        , shortName = ""
        , requiredToUnlock = 0
        , requirementStatus = 0
        }


getSceneFromIndex : List Scene -> Int -> Scene
getSceneFromIndex l i =
    let
        h =
            Maybe.withDefault emptyScene (List.head l)

        t =
            Maybe.withDefault [] (List.tail l)
    in
    if i == 0 then
        h

    else
        getSceneFromIndex t (i - 1)


getAbilityLevelFromIndex : List Int -> Int -> Int
getAbilityLevelFromIndex l i =
    case l of
        h :: t ->
            case i of
                0 ->
                    h

                _ ->
                    getAbilityLevelFromIndex t (i - 1)

        [] ->
            0


buildInner : Scene -> Model -> Html Msg
buildInner s m =
    case s of
        Enemy e ->
            buildEnemyScreen e m

        Cutscene c ->
            buildCutsceneScreen c


buildEnemyScreen : EnemyDesc -> Model -> Html Msg
buildEnemyScreen e m =
    div [ class "row" ]
        [ div [ class "col-3", style "border-right" "1px solid #e6e6e6" ]
            [ stagePicker m
            ]
        , div [ class "col-6", style "text-align" "justify" ]
            [ fightFragment e m
            ]
        , div [ class "col-3", style "border-left" "1px solid #e6e6e6" ]
            [ displayAbilities m.gameState.currency m.abilities m.gameState.activeAbilities

            --, displayCurrency m.gameState.currency
            ]
        ]


displayCurrency : Int -> Html Msg
displayCurrency c =
    h4 []
        [ text (String.fromInt c)
        , img [ src coinImageSrc, style "width" "1em", style "margin-top" "-6px" ] []
        ]


displayAbilities : Int -> List AbilityDescriptor -> List Int -> Html Msg
displayAbilities currency abilityList activeAbilities =
    let
        generateAbilityItems : List AbilityDescriptor -> List (Html Msg)
        generateAbilityItems a =
            case a of
                h :: t ->
                    div
                        [ class "list-group-item list-group-item-action" ]
                        [ h5 [ class "d-flex w-100 justify-content-between" ]
                            [ text h.name
                            , h6 [ style "margin-top" "2px" ] [ makeAbilityTypeBadge h.damageType ]
                            ]
                        , div [ class "row" ]
                            [ div [ class "col", style "text-align" "justify" ] [ text h.description ]
                            , div [ class "col-2", style "padding-left" "0" ]
                                [ img
                                    [ src h.image
                                    , style "width" "3em"
                                    , style "border" "1px solid #e6e6e6"
                                    , style "border-radius" "4px"
                                    ]
                                    []
                                ]
                            ]
                        , spacing
                        , div [ class "btn-group" ]
                            [ div [ class "input-group-prepend" ]
                                [ div [ class "input-group-text", style "line-height" "1" ]
                                    [ text ("Lvl. " ++ String.fromInt h.level) ]
                                ]
                            , button
                                [ onClick (BuyAbility h.index 1)
                                , attribute "type" "button"
                                , class "btn btn-secondary btn-sm"
                                , style "line-height" "1"
                                , disabled (isAbilityBuyActive h.price)
                                ]
                                [ text "+1" ]
                            , button
                                [ onClick (BuyAbility h.index 10)
                                , attribute "type" "button"
                                , class "btn btn-secondary btn-sm"
                                , style "line-height" "1"
                                , disabled (isAbilityBuyActive h.price)
                                ]
                                [ text "+10" ]
                            , div [ class "input-group-append" ]
                                [ div [ class "input-group-text", style "line-height" "1", title "Current price for one level" ]
                                    [ text (String.fromInt h.price)
                                    , img [ src coinImageSrc, style "width" "1em" ] []
                                    ]
                                ]
                            ]
                        ]
                        :: generateAbilityItems t

                [] ->
                    []

        isAbilityBuyActive price =
            currency < price

        makeAbilityTypeBadge : Int -> Html Msg
        makeAbilityTypeBadge t =
            case t of
                0 ->
                    span [ class "badge badge-pill badge-primary" ] [ text "Click" ]

                1 ->
                    span [ class "badge badge-pill badge-warning" ] [ text "Auto" ]

                _ ->
                    span [ class "badge badge-pill badge-danger" ] [ text "Error" ]
    in
    div []
        [ div [ class "d-flex w-100 justify-content-between" ]
            [ h4 [ style "padding-left" "4px", style "letter-spacing" "1px" ] [ text "Abilities" ]
            , displayCurrency currency
            ]
        , div [ class "list-group", style "margin-top" "16px" ]
            (generateAbilityItems abilityList)
        ]


stagePicker : Model -> Html Msg
stagePicker m =
    let
        generateSceneItems : List Scene -> List (Html Msg)
        generateSceneItems s =
            case s of
                h :: t ->
                    case h of
                        Cutscene c ->
                            case c.requiredToUnlock > c.requirementStatus of
                                True ->
                                    a
                                        [ class "list-group-item list-group-item-action disabled list-group-item-light", href "#", onClick (Navigate c.id False) ]
                                        [ i []
                                            [ text "???"
                                            , text " ("
                                            , span [ class "text-danger" ] [ text (String.fromInt c.requirementStatus ++ "/" ++ String.fromInt c.requiredToUnlock) ]
                                            , text ")"
                                            ]
                                        ]
                                        :: []

                                False ->
                                    a
                                        [ class "list-group-item list-group-item-action", href "#", onClick (Navigate c.id False) ]
                                        [ text (c.shortName ++ " ")
                                        , small []
                                            [ em []
                                                [ text "(Story)" ]
                                            ]
                                        ]
                                        :: generateSceneItems t

                        Enemy e ->
                            case e.requiredToUnlock > e.requirementStatus of
                                True ->
                                    a
                                        [ class "list-group-item list-group-item-action disabled list-group-item-light"
                                        , href "#"
                                        , onClick (Navigate e.id False)
                                        ]
                                        [ div [ class "d-flex w-100 justify-content-between" ]
                                            [ span []
                                                [ text "???"
                                                , text " ("
                                                , span [ class "text-danger" ] [ text (String.fromInt e.requirementStatus ++ "/" ++ String.fromInt e.requiredToUnlock) ]
                                                , text ")"
                                                ]
                                            ]
                                        ]
                                        :: []

                                False ->
                                    a
                                        [ class "list-group-item list-group-item-action"
                                        , href "#"
                                        , onClick (Navigate e.id False)
                                        ]
                                        [ div [ class "d-flex w-100 justify-content-between" ]
                                            [ span []
                                                [ text (e.name ++ " ")
                                                , small [] [ em [] [ text "(Enemy)" ] ]
                                                ]
                                            , img
                                                [ src e.imagePath
                                                , style "width" "1.75em"
                                                , style "border" "1px solid #e6e6e6"
                                                , style "border-radius" "4px"
                                                ]
                                                []
                                            ]
                                        ]
                                        :: generateSceneItems t

                _ ->
                    []
    in
    div []
        [ h4 [ style "padding-left" "4px", style "letter-spacing" "1px" ] [ text "Stages" ]
        , div [ class "list-group", style "margin-top" "16px", style "overflow-y" "auto", style "height" "10%" ] (generateSceneItems m.scenes)
        ]


fightFragment : EnemyDesc -> Model -> Html Msg
fightFragment enemy m =
    let
        timeRunningOut t =
            case t < levelTime * 0.2 of
                True ->
                    "bg-warning"

                False ->
                    "bg-info"
    in
    div []
        [ div [ style "font-size" "2.5em", style "text-align" "center", style "letter-spacing" "1px", style "text-shadow" "1px 1px 2px #000" ]
            [ a [] [ text enemy.name ] ]
        , div [ style "text-align" "center", style "font-style" "italic", style "font-weight" "300", style "letter-spacing" "2px" ]
            [ a [] [ text enemy.shortDescription ] ]
        , spacing
        , div [ style "text-align" "center" ] [ img [ src enemy.imagePath, style "width" "35%", onClick HitEnemy ] [] ]
        , spacing
        , div [] [ a [] [ text enemy.enemyDescription ] ]
        , doubleSpacing
        , div [ style "height" "30px", class "progress" ]
            [ div
                [ class "progress-bar bg-danger progress-bar-striped progress-bar-animated"
                , attribute "role" "progressbar"
                , style "width" (String.fromInt (round (toFloat (m.gameState.currentEnemyHP * 100) / toFloat enemy.enemyDefaultHP)) ++ "%")
                ]
                [ Html.text (String.fromInt m.gameState.currentEnemyHP ++ "/" ++ String.fromInt enemy.enemyDefaultHP ++ " HP") ]
            ]
        , spacing
        , div [ class "progress" ]
            [ div
                [ class "progress-bar progress-bar-striped progress-bar-animated"
                , attribute "role" "progressbar"
                , class (timeRunningOut (toFloat m.gameState.time))
                , style "width" (String.fromInt (round ((toFloat m.gameState.time * 100) / levelTime)) ++ "%")
                ]
                [ Html.text (String.fromInt (round (toFloat m.gameState.time / 100)) ++ " s") ]
            ]
        , doubleSpacing
        , Html.button
            [ onClick HitEnemy
            , Html.Attributes.attribute "type" "button"
            , Html.Attributes.class "btn btn-primary btn-block"
            ]
            [ Html.text "Hit!" ]

        --, Html.button
        --    [ Html.Events.onClick Next
        --    , Html.Attributes.attribute "type" "button"
        --    , Html.Attributes.class "btn btn-primary btn-block"
        --    ]
        --    [ Html.text "Next enemy" ]
        ]


buildCutsceneScreen : CutsceneDesc -> Html Msg
buildCutsceneScreen c =
    div []
        [ div []
            [ div [ style "text-align" "justify" ] [ c.content ]
            , doubleSpacing
            , Html.button
                [ Html.Events.onClick (Navigate (c.id + 1) True)
                , Html.Attributes.attribute "type" "button"
                , Html.Attributes.class "btn btn-primary btn-block"
                ]
                [ Html.text "Continue" ]
            ]
        ]


view : Model -> Html Msg
view m =
    let
        item =
            getSceneFromIndex m.scenes m.gameState.currentScene
    in
    div []
        [ div [ class "container", style "margin-bottom" "60px", style "width" "90%", style "max-width" "90%" ]
            [ div [ style "text-align" "center", style "margin" "10px 0 10px 0", class "d-flex w-100 justify-content-between" ]
                [ div [] [] -- left side of top game bar, if needed
                , img [ src gameLogoSrc, style "width" "20%" ] []
                , div [] [] -- right side of top game bar, if needed
                ]
            , div [ class "card" ]
                [ div [ class "card-body" ]
                    [ buildInner item m
                    ]
                ]
            ]
        , footer
            [ class "footer"
            , style "text-align" "center"
            , style "position" "fixed"
            , style "bottom" "0"
            , style "width" "100%"
            , style "line-height" "60px"
            , style "background-color" "#f5f5f5"
            ]
            [ div [ class "container" ] [ text "Written in Elm with ❤" ]
            ]
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg m =
    case msg of
        Navigate i b ->
            let
                newNumber =
                    modBy (List.length m.scenes) i

                hp =
                    case getSceneFromIndex m.scenes newNumber of
                        Enemy e ->
                            e.enemyDefaultHP

                        _ ->
                            666

                previousState =
                    m.gameState

                newGameState =
                    { previousState | currentScene = newNumber, time = levelTime, currentEnemyHP = hp }

                newScenes =
                    case b of
                        False ->
                            m.scenes

                        True ->
                            increaseRequirementForUnlock (previousState.currentScene + 1) m.scenes
            in
            case i == List.length scenes of
                True ->
                    ( { scenes = scenes
                      , abilities = abilities
                      , gameState = emptyGameState
                      }
                    , Cmd.none
                    )

                False ->
                    ( { m | gameState = newGameState, scenes = newScenes }, Cmd.none )

        HitEnemy ->
            let
                previousState =
                    m.gameState

                newHP =
                    case previousState.currentEnemyHP - calculateDamage 1 m.abilities < 0 of
                        True ->
                            0

                        False ->
                            previousState.currentEnemyHP - calculateDamage 1 m.abilities

                newGameState =
                    { previousState | currentEnemyHP = newHP }
            in
            ( { m | gameState = newGameState }, Cmd.none )

        BuyAbility abilityId quantity ->
            let
                previousStateLevels =
                    m.gameState
            in
            case quantity of
                0 ->
                    ( m, Cmd.none )

                x ->
                    let
                        previousGameState =
                            m.gameState

                        cost =
                            getAbilityPrice abilityId m.abilities

                        newAbilityState =
                            abilityPriceUp abilityId (abilityLevelUp abilityId m.abilities)

                        newGameState =
                            { previousGameState
                                | currency = previousGameState.currency - cost
                            }
                    in
                    case m.gameState.currency >= cost of
                        False ->
                            ( m, Cmd.none )

                        True ->
                            ( { m | gameState = newGameState, abilities = newAbilityState }, send (BuyAbility abilityId (quantity - 1)) )

        ReduceTime ->
            let
                hp =
                    case getSceneFromIndex m.scenes m.gameState.currentScene of
                        Enemy e ->
                            e.enemyDefaultHP

                        _ ->
                            666
            in
            if m.gameState.time <= 0 then
                let
                    previousState =
                        m.gameState

                    newGameState =
                        { previousState | time = levelTime, currentEnemyHP = hp }
                in
                ( { m | gameState = newGameState }, Cmd.none )

            else
                case m.gameState.currentEnemyHP <= 0 of
                    True ->
                        let
                            previousState =
                                m.gameState

                            reward =
                                calculateReward m.gameState.currentScene m.scenes

                            newGameState =
                                { previousState | time = levelTime, currency = previousState.currency + reward, currentEnemyHP = hp }

                            newScenes =
                                increaseRequirementForUnlock (previousState.currentScene + 1) m.scenes
                        in
                        ( { m | gameState = newGameState, scenes = newScenes }, Cmd.none )

                    _ ->
                        let
                            previousState =
                                m.gameState

                            newHP =
                                calcAutoDamage m

                            newGameState =
                                { previousState | time = previousState.time - 1, currentEnemyHP = newHP }
                        in
                        ( { m | gameState = newGameState }, Cmd.none )


calcAutoDamage : Model -> Int
calcAutoDamage m =
    let
        a =
            getAbilityFromIndex 1 m.abilities

        b =
            getAbilityFromIndex 2 m.abilities
    in
    case a of
        Just ab ->
            if modBy 100 m.gameState.time == 0 && ab.level > 0 && m.gameState.time /= levelTime then
                case b of
                    Just ab2 ->
                        m.gameState.currentEnemyHP - ab2.abilityDamageFunction (ab.abilityDamageFunction ab.damageQuantity ab.level) ab2.level

                    Nothing ->
                        m.gameState.currentEnemyHP - ab.abilityDamageFunction ab.damageQuantity ab.level

            else
                m.gameState.currentEnemyHP

        Nothing ->
            m.gameState.currentEnemyHP


getAbilityFromIndex : Int -> List AbilityDescriptor -> Maybe AbilityDescriptor
getAbilityFromIndex i l =
    case l of
        h :: t ->
            if i == 0 then
                Just h

            else
                getAbilityFromIndex (i - 1) t

        [] ->
            Nothing


send m =
    Task.succeed m
        |> Task.perform identity


calculateReward : Int -> List Scene -> Int
calculateReward sceneNumber s =
    case sceneNumber of
        0 ->
            case s of
                h :: t ->
                    case h of
                        Enemy e ->
                            e.reward

                        Cutscene c ->
                            0

                [] ->
                    0

        _ ->
            case s of
                h :: t ->
                    calculateReward (sceneNumber - 1) t

                _ ->
                    0


increaseRequirementForUnlock : Int -> List Scene -> List Scene
increaseRequirementForUnlock i s =
    case i of
        0 ->
            case s of
                h :: t ->
                    case Debug.log "Old scene" h of
                        Cutscene c ->
                            Cutscene { c | requirementStatus = c.requirementStatus + 1 } :: t

                        Enemy e ->
                            Enemy { e | requirementStatus = e.requirementStatus + 1 } :: t

                _ ->
                    s

        _ ->
            case s of
                h :: t ->
                    h :: increaseRequirementForUnlock (i - 1) t

                _ ->
                    s


calculateDamage : Int -> List AbilityDescriptor -> Int
calculateDamage baseDamage a =
    case a of
        h :: t ->
            case h.damageType of
                0 ->
                    calculateDamage (h.abilityDamageFunction baseDamage h.level) t

                _ ->
                    calculateDamage baseDamage t

        _ ->
            baseDamage


abilityLevelUp id abilityList =
    case id of
        0 ->
            case abilityList of
                h :: t ->
                    { h | level = h.level + 1 } :: t

                _ ->
                    []

        _ ->
            case abilityList of
                h :: t ->
                    h :: abilityLevelUp (id - 1) t

                _ ->
                    []


abilityPriceUp : Int -> List AbilityDescriptor -> List AbilityDescriptor
abilityPriceUp id a =
    case id of
        0 ->
            case a of
                h :: t ->
                    { h | price = h.abilityPriceIncrease h.price } :: t

                _ ->
                    []

        _ ->
            case a of
                h :: t ->
                    h :: abilityPriceUp (id - 1) t

                _ ->
                    []


getAbilityPrice : Int -> List AbilityDescriptor -> Int
getAbilityPrice id a =
    case id of
        0 ->
            case a of
                h :: _ ->
                    h.price

                _ ->
                    0

        _ ->
            case a of
                _ :: t ->
                    getAbilityPrice (id - 1) t

                _ ->
                    0


init : () -> ( Model, Cmd Msg )
init _ =
    ( { scenes = scenes
      , abilities = abilities
      , gameState = emptyGameState
      }
    , Cmd.none
    )


subscriptions : Model -> Sub Msg
subscriptions m =
    Time.every 10 (\_ -> ReduceTime)


main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
