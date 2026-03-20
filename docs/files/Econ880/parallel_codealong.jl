#= 
Codealong for Parallelization in Julia
Credit to Kevin Hunt for some code & explanations
=#


using Distributed #Gives functions and macros for distributed/multi-processing


################################################################################
# Set-Up for Parallelization
################################################################################

#How many processes are running in my session?
nprocs()

#How many workers? 
nworkers()

#Add 5 processes/workers
addprocs(5)

#=
Note: One of the processes is the master if you have more than one process. 
Master distributes tasks and work to the workers, but typically does not do 
any work itself. In order to get speed gains from distributing, you will need
to add at least two workers
=#

nprocs()                                        # Six processes
nworkers()                                      # But only five workers


#Each process is given an id.
myid()                                          #Prints processes id. 1 is the master, which you are currently running on. 

#@everywhere will run the following line of code on all processes. 
@everywhere @show myid()

#Get a list of processes and workers
procs()
workers()


#@spawn sends a line of code to an available worker
chosen_worker = @spawn myid()                       #Returns a Future object, which is a promise from the worker to do this later  
fetch(chosen_worker)                                #Fetch will make worker fulfill its promise.

#We can specifically choose the worker by using @spawnat
chosen_worker = @spawnat 3 myid()                   #This will always go to worker 3.
fetch(chosen_worker)


# can remove workers with rmprocs(i)
addprocs(1)
nprocs()
rmprocs(7)                                  # Remove worker 7
nprocs()
# can't remove master process
rmprocs(1) # warning here tells you it doesn't work
nprocs()




################################################################################
# Memory across processes
################################################################################

#Define r on master processes
r = rand()

#Other workers don't know what r is. 
@everywhere @show r

#Define a different r on every process
@everywhere r = rand()
@everywhere @show r                         #Every process generated a different random number!



################################################################################
# Pros and cons of parallelization
################################################################################

@everywhere function slow_square(x)         # define the function on all processes
    sleep(1)                                #Sleep for 1 second - simulates a slow process
    return x^2
end


@time for i in 1:6
    slow_square(i)                          # This will take 6 seconds to run
end


@time @sync for i in 1:6                    # @sync waits for all processes to finish
    @spawnat i slow_square(i)               # gives each worker a task
end

# only takes 1 second! But the memory allocation is much larger



@time for i in 1:6
    println(i^2)
end

@time @sync for i in 1:6
    @spawnat i println(i^2)
end

# this took longer! The overhead of parallelization is not always worth it.



@distributed for i in 1:6       # @distributed macro assigns tasks to workers automatically
    println(i)
end


# Normal Array define on the Master Process
A = rand(100)

# Inside a distributed for loop, workers will look for variables in the master's global Memory
# if that name variable doesn't exist in the worker's memory. 
@distributed for i in 1:6
    println(A[i])
end


# Worker's will copy this variable to their own global memory
# Workers will update A in their own global memory, but not on the master!
@distributed for i = eachindex(A)
    A[i] = A[i] + 1
end

#A was only update on the workers, but A on the master still has A[i] < 1 for all i
A

# workers have read access, but not write access




################################################################################
# Shared Arrays
################################################################################

#Shared Arrays are Arrays that both master and workers have read and write access to. 
using SharedArrays

#With shared arrays, workers have read and write ability onto the master's memory
A_shared = SharedArray(A)

# Can initialize vectors as shared arrays
B_shared = SharedArray{Float64}(100)


@sync @distributed for i in eachindex(A_shared)
    A_shared[i] = A_shared[i] + 1
end

A_shared # it worked on A shared

A # A not changed, the shared array is a copy