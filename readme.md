<h1>multi-core CPU</h1>
<p>this is the udgrade of schoolMIPS processor. Now it is multi-core (2) CPU with common RAM memory
<h2>Architecture</h2>
Common memory is divided on two equal parts. Each core can write only in its own part, but can read each cell of memory.
This approach have pros and cons: it is easier to design, but work with some types of data can be difficult to manage (for example, queue. Each core before work should check the latest version on its own write-part and on the write-part of the another core. It can read every cell of the memory:)</p>
<h2>Test program</h2>
In the test program placed in scrips folder the second core is continuosly writing in the memory growing number. The address is 0x0. The first core is reading it from the common memory and saving it in t1 register which can be displayed by the 9-value on switchers.
<h2>Instruction</h2>
<ol>
<li> Start the script of replacing files. The choice depends on your OS
<li> The usual sequence of schoolMIPS
</ol>
<h2>Important notes</h2>
<li> file for windows is not completed. Use git bash and cygwin et cetera on windows PC
<li>In the examples core 1 is reading information from the memory because it is connected to peripherals (value of registers can be displayed on 7 segments displays)
<li>Core 2 is not connected to peripherals because of my laziness</p>
<li>For this type of cores the memory is initialized from 0x0, so it won't be compiled in MARS program</p>