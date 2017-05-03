function PYTHON
    if which python3.6
        python3.6 $argv
    else
        python2.7 $argv
    end
end	
eval (PYTHON -m virtualfish auto_activation global_requirements compat_aliases)

function time -d "Use /usr/bin/time to display not only running time, but also memory usage"
	/usr/bin/time --format='%E wall, %Us user, %Ss sys 
%M kB max (%Xtext+%Ddata)
%P CPU' $argv
end
