﻿package eu.stefaner.relationbrowser.ui
{
  import eu.stefaner.relationbrowser.data.NodeData;

  import flare.animate.TransitionEvent;
  import flare.animate.Transitioner;
  import flare.util.Displays;
  import flare.vis.data.EdgeSprite;
  import flare.vis.data.NodeSprite;

  import flash.display.Sprite;
  import flash.events.Event;
  import flash.text.TextField;
  import flash.text.TextFormat;

  /**
   *Class description.
   *
   *@langversion ActionScript 3.0
   *@playerversion Flash 9.0
   *
   *@author mo
   *@since  05.11.2007
   */
  public class Node extends NodeSprite
  {

    public var title_tf:TextField;
    public var t:Transitioner;
    public var icon:Class;
    protected var iconAdded:Boolean;
    protected var iconSprite:Sprite;
    private var runningRollOverTransition:Boolean;
    private var doRollOutAfterTransitionEnd:Boolean;

    /**
     *@Constructor
     */
    public function Node(data:NodeData = null, icon:Class = null)
    {
      super();

      if(!title_tf)
      {
        createTitleField();
      }

      this.data = data;
      this.icon = icon;

      if(icon)
      {
        renderer = null;
      }

      mouseChildren = false;
      Displays.addStageListener(this, Event.ADDED_TO_STAGE, onStageInit);
    }

    protected function createTitleField():void
    {
      title_tf = new TextField();
      addChild(title_tf);
    }

    /**
     * PUBLIC
     */
    public override function render():void
    {
      super.render();

      if(icon && !iconAdded)
      {
        iconAdded = true;

        try
        {
          iconSprite = Sprite(addChildAt(new icon(), 0));
        }
        catch(e:Error)
        {
        }
      }

      if(data)
      {
        title_tf.text = data.label;
        title_tf.textColor = 0xFFFFFF;
        
        titleFormat = new TextFormat();
        titleFormat.font = "Verdana";
        title_tf.setTextFormat(titleFormat);        
        
        adjustTitleFieldSize();
      }
    }

    public function show(_t:Transitioner = null):void
    {
      _t = Transitioner.instance(_t);
      _t.$(this).alpha = 1;
      _t.$(this).visible = true;
      visible = true;
    }

    /**
     * PROTECTED
     */
    protected function adjustTitleFieldSize():void
    {
      title_tf.width = Math.min(title_tf.textWidth + 10, 90);
      title_tf.height = Math.min(title_tf.textHeight + 5, 100);
      title_tf.x = - .5 * title_tf.width;
      title_tf.y = - .5 * title_tf.height;
    }

    public function onClick():void
    {
    }

    /**
     * EVENT HANDLERS
     */
    public function onRollOver(e:Event = null):void
    {
      doRollOutAfterTransitionEnd = false;

      if(runningRollOverTransition)
      {
        return;
      }
      refreshTransitioner();
      t.$(this).scale = 1.25;
      t.play();
      runningRollOverTransition = true;
    }

    public function onRollOut(e:Event = null):void
    {
      if(runningRollOverTransition)
      {
        doRollOutAfterTransitionEnd = true;
        return;
      }
      doRollOutAfterTransitionEnd = false;
      refreshTransitioner();
      t.$(this).scale = 1;
      t.play();
    }

    private function refreshTransitioner():void
    {
      if(t != null)
      {
        t.reset();
        t.dispose();
      }
      t = new Transitioner(.33);

      t.addEventListener(TransitionEvent.STEP, onTransitionStep);
      t.addEventListener(TransitionEvent.END, onTransitionEnd);
    }

    private function onTransitionEnd(event:TransitionEvent):void
    {
      runningRollOverTransition = false;

      if(doRollOutAfterTransitionEnd)
      {
        doRollOutAfterTransitionEnd = false;
        onRollOut();
      }
    }

    private function onTransitionStep(event:TransitionEvent):void
    {
      visitEdges(function(e:EdgeSprite):void
      {
        e.dirty();
        e.render();
      });
    }

    protected function onStageInit():void
    {
      render();
    }

    /* 
     *  GETTER/SETTER
     */
    override public function get data():Object
    {
      return super.data;
    }

    override public function set data(data:Object):void
    {
      if(!data is NodeData)
      {
        throw new Error("NodeData expected!");
      }
      super.data = data;
      render();
    }

    private var _selected:Boolean;

    public function get selected():Boolean
    {
      return _selected;
    }

    public function set selected(value:Boolean):void
    {
      if(value !== _selected)
      {
        _selected = value;
      }

      if(value)
      {
        visited = true;
      }
    }

    private var _scale:Number = 1;

    public function get scale():Number
    {
      return _scale || Math.max(scaleX, scaleY);
    }

    public function set scale(scale:Number):void
    {
      scaleX = scale;
      scaleY = scale;
      _scale = scale;
    //title_tf.visible = scale > .66;
    }

    private var _edgeRadius:Number = - 1;

    public function get edgeRadius():Number
    {
      return _edgeRadius != -1 ? _edgeRadius * scale : Math.max(width, height) * .5 * 1.1;
    }

    public function set edgeRadius(edgeRadius:Number):void
    {
      _edgeRadius = edgeRadius;
    }

    private var _visited:Boolean = false;

    public function get visited():Boolean
    {
      return _visited;
    }

    public function set visited(visited:Boolean):void
    {
      _visited = visited;
    }
  }
}