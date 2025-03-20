#=
PROJECT | Advanced Programming Course (2024/2025)
Goal: implementation, in the Julia programming language, of the operations for 
the signaling and handling of exceptional situations, including the use of restarts

By: Ana Alfaiate 102903 ; Inês Trigueiro 102902 ; Raquel Coelho 102881
=#

module MyFunctions

export say_hello  # Allows the function to be used outside the module

function say_hello()
    println("Hello from a module!")
end

end # End of module

struct DivisionByZero <: Exception end

struct LineEndLimit <: Exception
end


#=  similar semantics to the block form of Common Lisp
to_escape establishes a named exit point to which the execution can be transferred by calling
the exit point. 
The Common Lisp form return_from does the actual escape to the corresponding
block but it is not needed in our implementation because the exit point is a function that, when
called, causes the escaping =#

struct myEscape <: Exception 
    args::Tuple
    exit_id::UInt64
end 

struct MyEscapeException
    value  # O valor retornado pelo exit
    exit_id::UInt64  # O identificador único do exit
end

function to_escape(func)
    let exit, exit_id = objectid(func)  # Criar um identificador único
        exit = (args...) -> throw(myEscape(args, exit_id))

        try
            return func(exit)
        catch e
            #=println("\n==== Capturou exceção ====")
            println("Tipo: ", typeof(e))
            println("Conteúdo: ", e)
            println("Exit original ID: ", exit_id)
            println("Exit capturado ID: ", e.exit_id)=#

            if e isa myEscape && e.exit_id == exit_id
                return length(e.args) == 1 ? e.args[1] : e.args
            else
                #println("ERRO: exit não bateu, repropagando...")
                rethrow()  # Repropaga exceções inesperadas
            end
        end
    end
end


function handling(func, handlers...)
    try 
        print("handling, try??? \n")
        func()
    catch e
        print("catch excecao handling?? \n")
        print(e)
        for (exception_type, handler_f) in handlers
            print(handler_f)
            if isa(e, exception_type)  
                print("Vamos resolver", e)
                handler_f(e)  
                #return  
                #rethrow(e)
            end
        end
        rethrow(e)  
    end
end

#handling(()->reciprocal(0),
#    DivisionByZero => (c)->println("I saw a division by zero"))

# handling(Exception Type => handler function)
handling(DivisionByZero =>
        (c)->println("I saw a division by zero")) do
    reciprocal(0)
end

struct RestartException <: Exception
    restart_name::Symbol
    args::Tuple
end

function with_restart(func, restarts...)
    restart_map = Dict(restarts...)
    #print(restarts)
    #print(restart_map)

    try
        print("try, restart \n")
        return func()
    catch e
        print("catch, restart \n")
        if e isa RestartException
            print("encontrei o restart exception")
            restart_name = e.restart_name
            if haskey(restart_map, restart_name)
                restart_function = restart_map[restart_name]
                # Invoca o ponto de recuperação, passando os argumentos
                return restart_function(e.args...)
            else
                throw(e)  # Se não encontrar o ponto de recuperação, repropaga a exceção
            end
        else
            print("envia para handling?")
            rethrow(e) # Repropaga qualquer outra exceção
        end
    end
end

function available_restart(name)

end


function invoke_restart(name, args...)
    throw(RestartException(name, args))
end

function signal(exception)

end    

function pa_error(exception::Exception)
    #Base.error
    throw(exception)  # Throw an error with the given message
end
