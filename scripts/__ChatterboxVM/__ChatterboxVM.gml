function __ChatterboxVM()
{
    content              = [];
    contentConditionBool = [];
    contentMetadata      = [];
    contentStructArray   = [];
    
    option               = [];
    optionConditionBool  = [];
    optionMetadata       = [];
    optionInstruction    = [];
    optionStructArray    = [];
    
    stopped          = false;
    waiting          = false;
    wait_instruction = undefined;
    entered_option   = false;
    leaving_option   = false;
    rejected_if      = false;
    
    if (current_instruction.type == "stop")
    {
        stopped = true;
        if (__CHATTERBOX_DEBUG_VM) __ChatterboxTrace("STOP");
        return undefined;
    }
    
    array_push(global.__chatterboxVMInstanceStack, self);
    global.__chatterboxCurrent = self;
    
    __ChatterboxVMInner(current_instruction);
    
    array_pop(global.__chatterboxVMInstanceStack);
    global.__chatterboxCurrent = (array_length(global.__chatterboxVMInstanceStack) <= 0)? undefined : global.__chatterboxVMInstanceStack[array_length(global.__chatterboxVMInstanceStack)-1];
    
    if (__CHATTERBOX_DEBUG_VM) __ChatterboxTrace("HALT");
}

function __ChatterboxVMInner(_instruction)
{
    var _do_next = true;
    var _next = variable_struct_get(_instruction, "next");
    
    if (is_string(_instruction.type))
    {
        var _condition_failed = false;
        
        if (!((_instruction.type == "if") || (_instruction.type == "else if")) && variable_struct_exists(_instruction, "condition"))
        {
            if (!__ChatterboxEvaluate(local_scope, filename, _instruction.condition, undefined)) _condition_failed = true;
        }
        
        if (CHATTERBOX_SHOW_REJECTED_OPTIONS || !_condition_failed)
        {
            if ((_instruction.type == "option") && !leaving_option)
            {
                entered_option = true;
                
                if (_instruction.type == "option")
                {
                    var _branch = variable_struct_get(_instruction, "option_branch");
                    if (_branch == undefined) _branch = variable_struct_get(_instruction, "next");
                    
                    var _optionString = _instruction.text.Evaluate(local_scope, filename, false);
                    array_push(option, _optionString);
                    array_push(optionConditionBool, !_condition_failed);
                    array_push(optionMetadata, _instruction.metadata);
                    array_push(optionInstruction, _branch);
                    
                    array_push(optionStructArray, {
                        text: _optionString,
                        conditionBool: !_condition_failed,
                        metadata: _instruction.metadata,
                    });
                    
                    if (__CHATTERBOX_DEBUG_VM) __ChatterboxTrace(__ChatterboxGenerateIndent(_instruction.indent), (_condition_failed? "<false> " : ""), "-> \"", _instruction.text.raw_string, "\"    ", instanceof(_branch));
                }
            }
            else
            {
                if ((_instruction.type != "option") && leaving_option) leaving_option = false;
            }
            
            if (entered_option)
            {
                if (_instruction.type != "option")
                {
                    _do_next = false;
                }
            }
            else
            {
                switch(_instruction.type)
                {
                    case "content":
                        var _contentString = _instruction.text.Evaluate(local_scope, filename, false);
                        array_push(content, _contentString);
                        array_push(contentConditionBool, !_condition_failed);
                        array_push(contentMetadata, _instruction.metadata);
                        
                        array_push(contentStructArray, {
                            text: _contentString,
                            conditionBool: !_condition_failed,
                            metadata: _instruction.metadata,
                        });
                        
                        if (__CHATTERBOX_DEBUG_VM) __ChatterboxTrace(__ChatterboxGenerateIndent(_instruction.indent), (_condition_failed? "<false> " : ""), _instruction.text.raw_string);
                        
                        if (singleton_text)
                        {
                            if (instanceof(_next) == "__ChatterboxClassInstruction")
                            {
                                if (((_next.type != "option") || CHATTERBOX_SINGLETON_WAIT_BEFORE_OPTION)
                                &&  (_next.type != "wait")
                                &&  (_next.type != "stop"))
                                {
                                    waiting = true;
                                    wait_instruction = _next;
                                    _do_next = false;
                                }
                            }
                        }
                    break;
                    
                    case "wait":
                        global.__chatterboxVMForceWait = true;
                        if (__CHATTERBOX_DEBUG_VM) __ChatterboxTrace(__ChatterboxGenerateIndent(_instruction.indent), "<<wait>>");
                    break;
                    
                    case "jump":
                        if (__CHATTERBOX_DEBUG_VM) __ChatterboxTrace(__ChatterboxGenerateIndent(_instruction.indent), "[goto ", _instruction.destination, "]");
                        
                        try
                        {
                            var _destination = __ChatterboxEvaluate(local_scope, filename, __ChatterboxParseExpression("(" + _instruction.destination + ")", false), undefined);
                        }
                        catch(_error)
                        {
                            //Catch e.g. <<jump A>> using a relaxed syntax
                            var _destination = _instruction.destination;
                        }
                        
                        var _split = __ChatterboxSplitGoto(_destination);
                        if (_split.filename == undefined)
                        {
                            var _next_node = FindNode(_split.node);
                            if (_next_node == undefined) __ChatterboxError("Node \"", _split.node, "\" could not be found in \"", filename, "\"");
                            _next_node.MarkVisited();
                            _next = _next_node.root_instruction;
                            current_node = _next_node;
                        }
                        else
                        {
                            var _file = global.chatterboxFiles[? _split.filename];
                            if (instanceof(_file) == "__ChatterboxClassSource")
                            {
                                file = _file;
                                filename = file.filename;
                                
                                _next_node = FindNode(_split.node);
                                if (_next_node == undefined) __ChatterboxError("Node \"", _split.node, "\" could not be found in \"", _split.filename, "\"");
                                _next_node.MarkVisited();
                                _next = _next_node.root_instruction;
                                current_node = _next_node;
                            }
                            else
                            {
                                __ChatterboxTrace("Error! File \"", _split.filename, "\" not found or not loaded");
                            }
                        }
                    break;
                    
                    case "stop":
                        if (CHATTERBOX_WAIT_BEFORE_STOP && (array_length(content) > 0) && (array_length(option) <= 0))
                        {
                            waiting = true;
                            wait_instruction = _instruction;
                        }
                        else
                        {
                            stopped = true;
                        }
                        
                        _do_next = false;
                        if (__CHATTERBOX_DEBUG_VM) __ChatterboxTrace(__ChatterboxGenerateIndent(_instruction.indent), "<<stop>>");
                    break;
                    
                    case "option end":
                        leaving_option = true;
                        if (__CHATTERBOX_DEBUG_VM) __ChatterboxTrace(__ChatterboxGenerateIndent(_instruction.indent), "<<option end>>");
                    break;
                    
                    case "declare":
                        if (__CHATTERBOX_DEBUG_VM) __ChatterboxTrace(_instruction.expression);
                        __ChatterboxEvaluate(local_scope, filename, _instruction.expression, "declare");
                    break;
                    
                    case "set":
                        if (__CHATTERBOX_DEBUG_VM) __ChatterboxTrace(_instruction.expression);
                        __ChatterboxEvaluate(local_scope, filename, _instruction.expression, "set");
                    break;
                    
                    case "direction":
                        if (__CHATTERBOX_DEBUG_VM) __ChatterboxTrace(_instruction.expression);
                        
                        var _direction_text = _instruction.text.Evaluate(local_scope, filename, true);
                        var _result = undefined;
                        
                        switch(CHATTERBOX_DIRECTION_MODE)
                        {
                            case 0:
                                if (is_method(CHATTERBOX_DIRECTION_FUNCTION))
                                {
                                    _result = CHATTERBOX_DIRECTION_FUNCTION(_direction_text);
                                }
                                else if (is_numeric(CHATTERBOX_DIRECTION_FUNCTION) && script_exists(CHATTERBOX_DIRECTION_FUNCTION))
                                {
                                    _result = script_execute(CHATTERBOX_DIRECTION_FUNCTION, _direction_text);
                                }
                            break;
                            
                            case 1:
                                _result = __ChatterboxEvaluate(local_scope, filename, __ChatterboxParseExpression(_direction_text, false), undefined);
                            break;
                            
                            case 2:
                                _result = __ChatterboxEvaluate(local_scope, filename, __ChatterboxParseExpression(_direction_text, true), undefined);
                            break;
                        }
                        
                        if (is_string(_result) && (_result == "<<wait>>"))
                        {
                            global.__chatterboxVMForceWait = true;
                            if (__CHATTERBOX_DEBUG_VM) __ChatterboxTrace(__ChatterboxGenerateIndent(_instruction.indent), "<<wait>> returned by function");
                        }
                    break;
                    
                    case "if":
                        if (__CHATTERBOX_DEBUG_VM) __ChatterboxTrace("<<if>> ", _instruction.condition);
                        
                        if (__ChatterboxEvaluate(local_scope, filename, _instruction.condition, undefined))
                        {
                            rejected_if = false;
                        }
                        else
                        {
                            rejected_if = true;
                            _next = variable_struct_get(_instruction, "branch_reject");
                        }
                    break;
                    
                    case "else":
                        if (__CHATTERBOX_DEBUG_VM) __ChatterboxTrace("<<else>>");
                        
                        if (!rejected_if)
                        {
                            _next = variable_struct_get(_instruction, "branch_reject");
                        }
                    break;
                    
                    case "else if":
                        if (__CHATTERBOX_DEBUG_VM) __ChatterboxTrace("<<else if>> ", _instruction.condition);
                        
                        if (rejected_if && __ChatterboxEvaluate(local_scope, filename, _instruction.condition, undefined))
                        {
                            rejected_if = false;
                        }
                        else
                        {
                            _next = variable_struct_get(_instruction, "branch_reject");
                        }
                    break;
                    
                    case "end if":
                        rejected_if = false;
                        if (__CHATTERBOX_DEBUG_VM) __ChatterboxTrace("<<end if>>");
                    break;
                    
                    default:
                        if (__CHATTERBOX_DEBUG_VM) __ChatterboxTrace("\"", _instruction.type, "\" instruction ignored");
                    break;
                }
            }
        }
    }
    
    if (global.__chatterboxVMForceWait)
    {
        global.__chatterboxVMForceWait = false;
        if (__CHATTERBOX_DEBUG_VM) __ChatterboxTrace(__ChatterboxGenerateIndent(_instruction.indent), "<<wait>> (forced)");
        
        waiting = true;
        wait_instruction = _instruction.next;
        _do_next = false;
    }
    
    if (_do_next)
    {
        if (instanceof(_next) == "__ChatterboxClassInstruction")
        {
            __ChatterboxVMInner(_next);
        }
        else
        {
            __ChatterboxTrace(__ChatterboxGenerateIndent(_instruction.indent), "Warning! Instruction found without next node (datatype=", instanceof(_next), ")");
            stopped = true;
        }
    }
}

/// @param string
function __ChatterboxSplitGoto(_string)
{
    var _pos = string_pos(CHATTERBOX_FILENAME_SEPARATOR, _string);
    if (_pos <= 0)
    {
        return {
            filename : undefined,
            node     : _string,
        };
    }
    else
    {
        return {
            filename : string_copy(_string, 1, _pos-1),
            node     : string_delete(_string, 1, _pos),
        };
    }
}