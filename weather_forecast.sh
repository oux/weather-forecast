#! /bin/bash

AREA_CODE=628886

CODE_TEXT_0="tornado"
CODE_SYMBOL_0="☈☈"
CODE_TEXT_1="tropical storm"
CODE_SYMBOL_1="☈"
CODE_TEXT_2="hurricane"
CODE_SYMBOL_2="☈"
CODE_TEXT_3="severe thunderstorms"
CODE_SYMBOL_3="severe thunderstorms"
CODE_SYMBOL_3="☈"
CODE_TEXT_4="thunderstorms"
CODE_SYMBOL_4="⛈"
CODE_SYMBOL_4="⛆"
CODE_SYMBOL_4="☈"
CODE_TEXT_5="mixed rain and snow"
CODE_SYMBOL_5="mixed rain and snow"
CODE_TEXT_6="mixed rain and sleet"
CODE_SYMBOL_6="mixed rain and sleet"
CODE_TEXT_7="mixed snow and sleet"
CODE_SYMBOL_7="mixed snow and sleet"
CODE_TEXT_8="freezing drizzle"
CODE_SYMBOL_8="☁"
CODE_TEXT_9="drizzle"
CODE_SYMBOL_9="☁"
CODE_TEXT_10="freezing rain"
CODE_SYMBOL_10="freezing rain"
CODE_TEXT_11="showers"
CODE_SYMBOL_11="☔"
CODE_SYMBOL_11="☇"
CODE_TEXT_12="showers"
CODE_SYMBOL_12="☔"
CODE_SYMBOL_12="☇"
CODE_TEXT_13="snow flurries"
CODE_SYMBOL_13="snow flurries"
CODE_TEXT_14="light snow showers"
CODE_SYMBOL_14="light snow showers"
CODE_TEXT_15="blowing snow"
CODE_SYMBOL_15="blowing snow"
CODE_TEXT_16="snow"
CODE_SYMBOL_16="snow"
CODE_TEXT_17="hail"
CODE_SYMBOL_17="hail"
CODE_TEXT_18="sleet"
CODE_SYMBOL_18="sleet"
CODE_TEXT_19="dust"
CODE_SYMBOL_19="dust"
CODE_TEXT_20="foggy"
CODE_SYMBOL_20="foggy"
CODE_TEXT_21="haze"
CODE_SYMBOL_21="haze"
CODE_TEXT_22="smoky"
CODE_SYMBOL_22="smoky"
CODE_TEXT_23="blustery"
CODE_SYMBOL_23="blustery"
CODE_TEXT_24="windy"
CODE_SYMBOL_24="windy"
CODE_TEXT_25="cold"
CODE_SYMBOL_25="cold"
CODE_TEXT_26="cloudy"
CODE_SYMBOL_26="☁"
CODE_TEXT_27="mostly cloudy (night)"
CODE_SYMBOL_27="☁☁"
CODE_TEXT_28="mostly cloudy (day)"
CODE_SYMBOL_28="☁☁"
CODE_TEXT_29="partly cloudy (night)"
CODE_SYMBOL_29="☁☁"
CODE_TEXT_30="partly cloudy (day)"
CODE_SYMBOL_30="⛅"
CODE_SYMBOL_30="☁"
CODE_TEXT_31="clear (night)"
CODE_SYMBOL_31="☉"
CODE_SYMBOL_31="☀"
CODE_TEXT_32="sunny"
CODE_SYMBOL_32="☼"
CODE_SYMBOL_31="☉"
CODE_TEXT_33="fair (night)"
CODE_SYMBOL_33="fair (night)"
CODE_SYMBOL_33="☉"
CODE_TEXT_34="fair (day)"
CODE_SYMBOL_34="fair (day)"
CODE_SYMBOL_34="☉"
CODE_TEXT_35="mixed rain and hail"
CODE_SYMBOL_35="mixed rain and hail"
CODE_TEXT_36="hot"
CODE_SYMBOL_36="hot"
CODE_TEXT_37="isolated thunderstorms"
CODE_SYMBOL_37="isolated thunderstorms"
CODE_TEXT_38="scattered thunderstorms"
CODE_SYMBOL_38="☈"
CODE_TEXT_39="scattered thunderstorms"
CODE_SYMBOL_39="☈"
CODE_TEXT_40="scattered showers"
CODE_SYMBOL_40="☔"
CODE_TEXT_41="heavy snow"
CODE_SYMBOL_41="heavy snow"
CODE_TEXT_42="scattered snow showers"
CODE_SYMBOL_42="scattered snow showers"
CODE_TEXT_43="heavy snow"
CODE_SYMBOL_43="heavy snow"
CODE_TEXT_44="partly cloudy"
CODE_SYMBOL_44="☁"
CODE_TEXT_45="thundershowers"
CODE_SYMBOL_45="☔"
CODE_SYMBOL_45="☇"
CODE_TEXT_46="snow showers"
CODE_SYMBOL_46="snow showers"
CODE_TEXT_47="isolated thundershowers"
CODE_SYMBOL_47="isolated thundershowers"
CODE_TEXT_3200="not available"
CODE_SYMBOL_3200="not available"

WEATHER_CACHE=/tmp/forecast
CACHE_TTL=3000

if ! [ -f $WEATHER_CACHE ] || [ $(($(stat --printf="%X" $WEATHER_CACHE 2>/dev/null) + $CACHE_TTL)) -lt $(date +%s) -o $(stat --printf="%s" $WEATHER_CACHE) -eq 0 ]
then
    /usr/bin/curl --silent "http://weather.yahooapis.com/forecastrss?w=$AREA_CODE&u=c" > $WEATHER_CACHE
fi

case "$1" in
    -c|--code)
        sed -n '/<yweather:forecast.*low="\([^"]*\)".*high="\([^"]*\)".*code="\([^"]*\)".*/{s%%\2/\1 \3%;H;};${g;s/^\n//;s/\n/|/gp;}' $WEATHER_CACHE
        VERBOSE=SYMBOL
        ;;
    -d|--debug)
        VERBOSE=TEXT
        ;;
    -i|-s|--i3|--symbol)
        VERBOSE=SYMBOL
        ;;
    -t|--tomorrow)
        awk -F '- '  '
        /<title>/ { sub("</title>", "", $2) && l=$2 }
        /<b>Forecast/ { getline; gsub("<.*", "", $2); printf("%s: %s - %s\n", l, $1, $2); exit }' $WEATHER_CACHE
        ;;
    -h|--help)
        cat << EOF
  usage:
        $0 -c|--code: to get the  weather code\
        $0 -d|--debug: to get the text version of weather code
        $0 -i|-s|--i3|--symbol: to get the symbolic output (using unicode chars for (almost) all kind of weather.)
        $0 -t|--tomorrow: original output example with awk...
EOF
        exit
        ;;
    *)
        sed -n '/<yweather:forecast.*low="\([^"]*\)".*high="\([^"]*\)".*text="\([^"]*\)".*/{s%%\2/\1 \3%;H;};${g;s/^\n//;s/\n/|/gp;}' $WEATHER_CACHE
        exit
esac

# RES=$(echo -e "\e[1;33m")
RES=$(sed -n '/<yweather:forecast.*day="\(.\).*low="\([^"]*\)".*high="\([^"]*\)".*code="\([^"]*\)".*/{s%%\1:${CODE_'${VERBOSE}'_\4}\3/\2%;H;};${g;s/^\n/echo /;s/\n/\\ /gp;}' $WEATHER_CACHE)
eval "$RES"
