# \#PROCJAM
Check out ProcJam [here](http://www.procjam.com/)

This is a project I'm doing for my "AI For Games" class at WPI. Here's what I plan to do in the order I plan to do it

## Plan:
Make a procedural medieval map generator. 
1. Place castles around the map
2. Partition territories off using a Voronoi Diagram
3. Add a terrain generation system (height map or something) and make the territory partitioner take terrain into consideration
4. Color the map in to make it look like an old scroll
And if I have time:
5. Make a Markov chain to procedurally generate names of castles and families living in them. 

One major constraint I'd like to have is that a single seed to the RNG produces the same map every time, so maps can be shared using just the seed. A bit of consideration is needed for this to work.
