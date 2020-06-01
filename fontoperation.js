import Operation from "../../core/operation/operation";
import isText from "../../util/dom/istext";
import splitTextNode from "../../util/dom/splittextnode";

export default class FontOperation extends Operation{
    constructor(context) {
        super(context);
        this._native=false
    }

    execute() {
        let me=this;
        let value=this.context.value;
        let selection = window.getSelection(), editor = this.editor;
        let range=selection.getRangeAt(0);
        let newNode;
        let startOffset=range.startOffset,endOffset=range.endOffset;
        let startContainer=range.startContainer,endContainer=range.endContainer;

        if(isText(startContainer)&&isText(endContainer)&&startContainer.parentElement.isEqualNode(endContainer.parentElement)){
            if(startOffset!==0||endOffset!==endContainer.data.length){
                newNode=this._splitText(startContainer.parentElement,startOffset,endOffset);
                range.setStart(newNode.firstChild,0);
                range.setEnd(newNode.firstChild,newNode.firstChild.data.length);
            }   
        }else{
            if(isText(startContainer)&&range.startOffset!==0){
                this._splitText(startContainer.parentElement,range.startOffset)
            }
            if(isText(endContainer)&&range.endOffset!==endContainer.data.length){
                this._splitText(endContainer.parentElement,range.endOffset,true)
            }
        }
        let selectedTextNodes=this.batch.editor.context.getTextNodes();
        selectedTextNodes.map(function (wordNode) {
            if(isText(wordNode.firstChild)){
                wordNode.style[me.batch.command.name]=value
            }
        })
    }

}
