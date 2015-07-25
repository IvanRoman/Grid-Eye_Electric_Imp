//I2C on pin 1 and 2
i2c <- hardware.i2c12;

hardware.i2c12.configure(CLOCK_SPEED_100_KHZ);

//Original I2C address is 0x068. Shifted to the right one bit is 0xD0
const i2c_grideye = 0xD0;


function GridEye(){
  //server.log("Beginning Program")
  local pixelTempL = "\x80";
	local aveTemp = 0;
	local celsius = 0;
	local image = i2c.read(i2c_grideye, pixelTempL, 64*2)

	for(local pixel = 0; pixel < 127; pixel += 2)
	{
		local lowerLevel = image[pixel];
		local upperLevel = image[pixel + 1];

    //server.log("Lower Level " + lowerLevel)
		//server.log("Upper Level " + upperLevel)

		local temperature = ((upperLevel << 8) | lowerLevel);
		if (temperature > 2047){
			temperature = temperature - 4096;
		}

		celsius = temperature * 0.25;

		aveTemp += celsius;
	}

	i2c.write(i2c_grideye, "\x0E")
	local upperLevelTherm = i2c.read(i2c_grideye, "", 1);
	local lowerLevelTherm = i2c.read(i2c_grideye, "", 1);
  upperLevelTherm = upperLevelTherm[0]
  lowerLevelTherm = lowerLevelTherm[0]

	local temperatureTherm = ((lowerLevelTherm << 8) | upperLevelTherm);
	local thermReading = temperatureTherm * 0.0625;

  //Average of all 64 pixels
	aveTemp *= 0.015625;

  //Output Results
	server.log("Average Temperature: " + aveTemp)
	server.log("Thermistor Reading: " + thermReading)
	imp.wakeup(0.25, GridEye)
}

GridEye();
