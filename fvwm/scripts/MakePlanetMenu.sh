fvwm_icon=$HOME/.fvwm/icons

wait=300
config=mine
common_options="-labelpos -0-0 -transparency -marker_file brightStars -wait ${wait} -config ${config}" 

function MakePlanetThumbnail() {                               
  if [ ! -f ${fvwm_icon}/planets/${1}.png ]; then 
    echo "Exec exec xplanet -num_times 1 -target ${1} -origin sun -geometry 22x22 -transpng -config ${config} -output ${fvwm_icon}/planets/${1}.png"
    fi
};                                                              

function MakeMoonsMenu() {	
  i=0

  for body in $*; do 

    MakePlanetThumbnail ${body}

    if [ $i -gt 0 ]; then 			# this is a moon

      echo "AddToMenu ${planet}Menu \"${body} from ${planet}%planets/${body}.png%\" Exec exec nice -n 19 xplanet ${common_options} -body ${body} -origin ${planet}"
      echo "AddToMenu ${planet}Menu \"${body} from earth%planets/${body}.png%\" Exec exec nice -n 19 xplanet ${common_options} -body ${body} -origin earth"

    else 					# this is a planet

      planet=${body}

      if [ "$#" -gt 1 ]; then			# planet has moons

	# make a new submenu to the planets menu
        echo "DestroyMenu ${planet}Menu"
	echo "AddToMenu PlanetsMenu ${planet}%planets/${planet}.png% Popup ${planet}Menu"

	if [ ${planet} == "earth" ]; then	# handle earth especially

	  echo "AddToMenu ${planet}Menu %planets/${planet}.png%${planet} Exec exec nice -n 19 xplanet ${common_options} -body earth"
	  echo "AddToMenu ${planet}Menu \"%planets/${planet}.png%${planet} from sun\" Exec exec nice -n 19 xplanet ${common_options} -body earth -origin sun"
	  echo "AddToMenu ${planet}Menu \"%planets/${planet}.png%${planet} from moon\" Exec exec nice -n 19 xplanet ${common_options} -body earth -origin moon"
	  echo "AddToMenu ${planet}Menu \"%planets/${planet}.png%${planet} (Berlin)\"  Exec exec nice -n 19 xplanet ${common_options} -body earth -latitude 52.5 -longitude 13.41667"
	  echo "AddToMenu   ${planet}Menu \"%planets/${planet}.png%${planet} (from Neptune)\"  Exec exec nice -n 19 xplanet ${common_options} -body earth -config earth+moon -north orbit -radius 25 -origin nep"

	else					# another planet
	  
 	  echo "AddToMenu ${planet}Menu \"%planets/${planet}.png%${planet} from earth\" Exec exec nice -n 19 xplanet ${common_options} -body ${body}"

	fi
	
      else					# no moons, just one entry
        echo "AddToMenu PlanetsMenu ${body}%planets/${body}.png% Exec exec nice -n 19 xplanet ${common_options} -body ${body}"
      fi
    fi	
    i=$[$i+1]
  done
}

for system in sun mercury venus "earth moon" "mars phobos deimos"		 \
	"jupiter io europa ganymede callisto"					 \
	"saturn mimas enceladus tethys dione rhea titan hyperion iapetus phoebe" \
	"uranus miranda ariel umbriel titania oberon"				 \
	"neptune triton nereid" "pluto charon"; 
do 
  MakeMoonsMenu ${system}
done
