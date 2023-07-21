// Created By Rafi for POC purpose.

public with sharing class AttachmentController {
    
    public Attachment attachment { get; private set; }
    public String attachmentBody { get; set; }
    
    public AttachmentController() {
        String attachmentId = '00P5g00000C6y5H';
        this.attachment = [SELECT Id, Body, ContentType, Name FROM Attachment WHERE Id = :attachmentId];
        System.debug('attachment body : '+EncodingUtil.base64Encode(attachment.Body));
    }
    
    public String getAttachmentBody() {
        attachmentBody = EncodingUtil.base64Encode(attachment.Body);
        System.debug('attachment body : '+attachmentBody);
        return attachmentBody;
    }
    
}