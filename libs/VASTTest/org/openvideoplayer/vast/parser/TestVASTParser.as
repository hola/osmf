/*****************************************************
*  
*  Copyright 2009 Adobe Systems Incorporated.  All Rights Reserved.
*  
*****************************************************
*  The contents of this file are subject to the Mozilla Public License
*  Version 1.1 (the "License"); you may not use this file except in
*  compliance with the License. You may obtain a copy of the License at
*  http://www.mozilla.org/MPL/
*   
*  Software distributed under the License is distributed on an "AS IS"
*  basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
*  License for the specific language governing rights and limitations
*  under the License.
*   
*  
*  The Initial Developer of the Original Code is Adobe Systems Incorporated.
*  Portions created by Adobe Systems Incorporated are Copyright (C) 2009 Adobe Systems 
*  Incorporated. All Rights Reserved. 
*  
*****************************************************/
package org.openvideoplayer.vast.parser
{
	import flexunit.framework.TestCase;
	
	import org.openvideoplayer.vast.model.VASTAd;
	import org.openvideoplayer.vast.model.VASTCompanionAd;
	import org.openvideoplayer.vast.model.VASTDocument;
	import org.openvideoplayer.vast.model.VASTInlineAd;
	import org.openvideoplayer.vast.model.VASTNonLinearAd;
	import org.openvideoplayer.vast.model.VASTResourceType;
	import org.openvideoplayer.vast.model.VASTTrackingEvent;
	import org.openvideoplayer.vast.model.VASTTrackingEventType;
	import org.openvideoplayer.vast.model.VASTUrl;
	import org.openvideoplayer.vast.model.VASTVideoClick;
	import org.openvideoplayer.vast.model.VASTWrapperAd;
		
	public class TestVASTParser extends TestCase
	{
		override public function setUp():void
		{
			super.setUp();
			
			parser = new VASTParser();
		}
		
		override public function tearDown():void
		{
			super.tearDown();
			
			parser = null;
		}
		
		//---------------------------------------------------------------------
		
		// Success cases
		//

		public function testParseInvalidDocuments():void
		{
			assertTrue(parser.parse(new XML()) == null);
			assertTrue(parser.parse(<foo/>) == null);
			
			try
			{
				parser.parse(null);
				
				fail();
			}
			catch (error:ArgumentError)
			{
				// Swallow.
			}
		}
		
		public function testParseInlineAd():void
		{
			var document:VASTDocument = parser.parse(INLINE_VAST_DOCUMENT);
			assertTrue(document != null);
			assertTrue(document.ads.length == 1);
			var vastAd:VASTAd = document.ads[0];
			assertTrue(vastAd != null);
			assertTrue(vastAd.id == "myinlinead");
			assertTrue(vastAd.inlineAd != null);
			assertTrue(vastAd.wrapperAd == null);
			
			var inlineAd:VASTInlineAd = vastAd.inlineAd;
			
			assertTrue(inlineAd.adSystem == "DART");
			assertTrue(inlineAd.adTitle == "Spiderman 3 Trailer");
			assertTrue(inlineAd.description == "Spiderman video trailer");
			assertTrue(inlineAd.errorURL == "http://www.primarysite.com/tracker?noPlay=true&impressionTracked=false");
			assertTrue(inlineAd.surveyURL == "http://www.dynamiclogic.com/tracker?campaignId=234&site=yahoo");
			
			assertTrue(inlineAd.impressions != null);
			assertTrue(inlineAd.impressions.length == 2);
			var impression:VASTUrl = inlineAd.impressions[0];
			assertTrue(impression.id == "myadsever");
			assertTrue(impression.url == "http://www.primarysite.com/tracker?imp");
			impression = inlineAd.impressions[1];
			assertTrue(impression.id == "anotheradsever");
			assertTrue(impression.url == "http://www.thirdparty.com/tracker?imp");
			
			assertTrue(inlineAd.trackingEvents != null);
			assertTrue(inlineAd.trackingEvents.length == 10);
			
			var trackingEvent:VASTTrackingEvent = inlineAd.trackingEvents[0];
			assertTrue(trackingEvent.type == VASTTrackingEventType.START);
			assertTrue(trackingEvent.urls.length == 1);
			var trackingURL:VASTUrl = trackingEvent.urls[0];
			assertTrue(trackingURL.id == "myadsever");
			assertTrue(trackingURL.url == "http://www.primarysite.com/tracker?start");
			
			trackingEvent = inlineAd.trackingEvents[1];
			assertTrue(trackingEvent.type == VASTTrackingEventType.MIDPOINT);
			assertTrue(trackingEvent.urls.length == 2);
			trackingURL = trackingEvent.urls[0];
			assertTrue(trackingURL.id == "myadsever");
			assertTrue(trackingURL.url == "http://www.primarysite.com/tracker?mid");
			trackingURL = trackingEvent.urls[1];
			assertTrue(trackingURL.id == "anotheradsever");
			assertTrue(trackingURL.url == "http://www.thirdparty.com/tracker?mid");

			trackingEvent = inlineAd.trackingEvents[2];
			assertTrue(trackingEvent.type == VASTTrackingEventType.FIRST_QUARTILE);
			assertTrue(trackingEvent.urls.length == 2);
			trackingURL = trackingEvent.urls[0];
			assertTrue(trackingURL.id == "myadsever");
			assertTrue(trackingURL.url == "http://www.primarysite.com/tracker?fqtl");
			trackingURL = trackingEvent.urls[1];
			assertTrue(trackingURL.id == "anotheradsever");
			assertTrue(trackingURL.url == "http://www.thirdparty.com/tracker?fqtl");

			trackingEvent = inlineAd.trackingEvents[3];
			assertTrue(trackingEvent.type == VASTTrackingEventType.THIRD_QUARTILE);
			assertTrue(trackingEvent.urls.length == 2);
			trackingURL = trackingEvent.urls[0];
			assertTrue(trackingURL.id == "myadsever");
			assertTrue(trackingURL.url == "http://www.primarysite.com/tracker?tqtl");
			trackingURL = trackingEvent.urls[1];
			assertTrue(trackingURL.id == "anotheradsever");
			assertTrue(trackingURL.url == "http://www.thirdparty.com/tracker?tqtl");

			trackingEvent = inlineAd.trackingEvents[4];
			assertTrue(trackingEvent.type == VASTTrackingEventType.COMPLETE);
			assertTrue(trackingEvent.urls.length == 2);
			trackingURL = trackingEvent.urls[0];
			assertTrue(trackingURL.id == "myadsever");
			assertTrue(trackingURL.url == "http://www.primarysite.com/tracker?comp");
			trackingURL = trackingEvent.urls[1];
			assertTrue(trackingURL.id == "anotheradsever");
			assertTrue(trackingURL.url == "http://www.thirdparty.com/tracker?comp");

			trackingEvent = inlineAd.trackingEvents[5];
			assertTrue(trackingEvent.type == VASTTrackingEventType.MUTE);
			assertTrue(trackingEvent.urls.length == 1);
			trackingURL = trackingEvent.urls[0];
			assertTrue(trackingURL.id == "myadsever");
			assertTrue(trackingURL.url == "http://www.primarysite.com/tracker?mute");

			trackingEvent = inlineAd.trackingEvents[6];
			assertTrue(trackingEvent.type == VASTTrackingEventType.PAUSE);
			assertTrue(trackingEvent.urls.length == 1);
			trackingURL = trackingEvent.urls[0];
			assertTrue(trackingURL.id == "myadsever");
			assertTrue(trackingURL.url == "http://www.primarysite.com/tracker?pause");

			trackingEvent = inlineAd.trackingEvents[7];
			assertTrue(trackingEvent.type == VASTTrackingEventType.REPLAY);
			assertTrue(trackingEvent.urls.length == 1);
			trackingURL = trackingEvent.urls[0];
			assertTrue(trackingURL.id == "myadsever");
			assertTrue(trackingURL.url == "http://www.primarysite.com/tracker?replay");

			trackingEvent = inlineAd.trackingEvents[8];
			assertTrue(trackingEvent.type == VASTTrackingEventType.FULLSCREEN);
			assertTrue(trackingEvent.urls.length == 1);
			trackingURL = trackingEvent.urls[0];
			assertTrue(trackingURL.id == "myadsever");
			assertTrue(trackingURL.url == "http://www.primarysite.com/tracker?full");

			trackingEvent = inlineAd.trackingEvents[9];
			assertTrue(trackingEvent.type == VASTTrackingEventType.STOP);
			assertTrue(trackingEvent.urls.length == 1);
			trackingURL = trackingEvent.urls[0];
			assertTrue(trackingURL.id == "myadsever");
			assertTrue(trackingURL.url == "http://www.primarysite.com/tracker?stop");
			
			assertTrue(inlineAd.companionAds != null);
			assertTrue(inlineAd.companionAds.length == 4);
			
			var companion:VASTCompanionAd = inlineAd.companionAds[0];
			assertTrue(companion.id == "rich media banner");
			assertTrue(companion.width == 468);
			assertTrue(companion.height == 60);
			assertTrue(companion.resourceType == VASTResourceType.IFRAME);
			assertTrue(companion.creativeType == "any");
			assertTrue(companion.url == "http://ad.server.com/adi/etc.html");
			assertTrue(companion.adParameters == null);
			assertTrue(companion.altText == null);
			assertTrue(companion.clickThroughURL == null);
			assertTrue(companion.code == null);
			assertTrue(companion.expandedWidth == 0);
			assertTrue(companion.expandedHeight == 0);

			companion = inlineAd.companionAds[1];
			assertTrue(companion.id == "banner1");
			assertTrue(companion.width == 728);
			assertTrue(companion.height == 90);
			assertTrue(companion.resourceType == VASTResourceType.SCRIPT);
			assertTrue(companion.creativeType == "any");
			assertTrue(companion.url == "http://ad.server.com/adj/etc.js");
			assertTrue(companion.adParameters == null);
			assertTrue(companion.altText == null);
			assertTrue(companion.clickThroughURL == null);
			assertTrue(companion.code == null);
			assertTrue(companion.expandedWidth == 0);
			assertTrue(companion.expandedHeight == 0);

			companion = inlineAd.companionAds[2];
			assertTrue(companion.id == "banner2");
			assertTrue(companion.width == 468);
			assertTrue(companion.height == 60);
			assertTrue(companion.resourceType == VASTResourceType.STATIC);
			assertTrue(companion.creativeType == "JPEG");
			assertTrue(companion.url == "http://media.doubleclick.net/foo.jpg");
			assertTrue(companion.adParameters == null);
			assertTrue(companion.altText == null);
			assertTrue(companion.clickThroughURL == "http://www.primarysite.com/tracker?click");
			assertTrue(companion.code == null);
			assertTrue(companion.expandedWidth == 0);
			assertTrue(companion.expandedHeight == 0);

			companion = inlineAd.companionAds[3];
			assertTrue(companion.id == "banner3");
			assertTrue(companion.width == 468);
			assertTrue(companion.height == 60);
			assertTrue(companion.resourceType == VASTResourceType.STATIC);
			assertTrue(companion.creativeType == "JPEG");
			assertTrue(companion.url == null);
			assertTrue(companion.adParameters == "param=value");
			assertTrue(companion.altText == "some alt text");
			assertTrue(companion.clickThroughURL == "http://www.primarysite.com/tracker?click");
			assertTrue(companion.code == "insert code here");
			assertTrue(companion.expandedWidth == 728);
			assertTrue(companion.expandedHeight == 90);

			assertTrue(inlineAd.nonLinearAds != null);
			assertTrue(inlineAd.nonLinearAds.length == 3);
			
			var nonLinearAd:VASTNonLinearAd = inlineAd.nonLinearAds[0];
			assertTrue(nonLinearAd.id == "overlay");
			assertTrue(nonLinearAd.width == 150);
			assertTrue(nonLinearAd.height == 60);
			assertTrue(nonLinearAd.resourceType == VASTResourceType.STATIC);
			assertTrue(nonLinearAd.creativeType == "SWF");
			assertTrue(nonLinearAd.url == "http://ad.server.com/adx/etc.xml");
			assertTrue(nonLinearAd.adParameters == null);
			assertTrue(nonLinearAd.clickThroughURL == "http://www.thirdparty.com/tracker?click");
			assertTrue(nonLinearAd.code == null);
			assertTrue(nonLinearAd.expandedWidth == 0);
			assertTrue(nonLinearAd.expandedHeight == 0);
			assertTrue(nonLinearAd.scalable == false);
			assertTrue(nonLinearAd.maintainAspectRatio == false);
			assertTrue(nonLinearAd.apiFramework == "IAB");

			nonLinearAd = inlineAd.nonLinearAds[1];
			assertTrue(nonLinearAd.id == "bumper");
			assertTrue(nonLinearAd.width == 250);
			assertTrue(nonLinearAd.height == 300);
			assertTrue(nonLinearAd.resourceType == VASTResourceType.STATIC);
			assertTrue(nonLinearAd.creativeType == "JPEG");
			assertTrue(nonLinearAd.url == "http://ad.doubleclick.net/adx/etc.jpg");
			assertTrue(nonLinearAd.adParameters == null);
			assertTrue(nonLinearAd.clickThroughURL == "http://www.thirdparty.com/tracker?click");
			assertTrue(nonLinearAd.code == null);
			assertTrue(nonLinearAd.expandedWidth == 0);
			assertTrue(nonLinearAd.expandedHeight == 0);
			assertTrue(nonLinearAd.scalable == false);
			assertTrue(nonLinearAd.maintainAspectRatio == false);
			assertTrue(nonLinearAd.apiFramework == null);
			
			nonLinearAd = inlineAd.nonLinearAds[2];
			assertTrue(nonLinearAd.id == "overlay2");
			assertTrue(nonLinearAd.width == 350);
			assertTrue(nonLinearAd.height == 100);
			assertTrue(nonLinearAd.resourceType == VASTResourceType.OTHER);
			assertTrue(nonLinearAd.creativeType == "JPEG");
			assertTrue(nonLinearAd.adParameters == "param=value");
			assertTrue(nonLinearAd.clickThroughURL == "http://www.thirdparty.com/tracker?click2");
			assertTrue(nonLinearAd.code == "insert code here");
			assertTrue(nonLinearAd.expandedWidth == 728);
			assertTrue(nonLinearAd.expandedHeight == 90);
			assertTrue(nonLinearAd.scalable == true);
			assertTrue(nonLinearAd.maintainAspectRatio == true);
			assertTrue(nonLinearAd.apiFramework == null);
			
			assertTrue(inlineAd.extensions != null);
			assertTrue(inlineAd.extensions.length == 1);
			
			var extension:XML = inlineAd.extensions[0];
			var expectedXML:XML =
				<Extension type="adServer" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
					<TemplateVersion>3.002</TemplateVersion>
					<AdServingData>
						<DeliveryData>
							<GeoData><![CDATA[ct=US&st=VA&ac=703&zp=20151&bw=4&dma=13&city=15719]]></GeoData>
							<MyAdId>43534850</MyAdId>
						</DeliveryData>
					</AdServingData>
				</Extension>;
			assertTrue(extension.toXMLString() == expectedXML.toXMLString());
		}

		public function testParseWrapperAd():void
		{
			var document:VASTDocument = parser.parse(WRAPPER_VAST_DOCUMENT);
			assertTrue(document != null);
			assertTrue(document.ads.length == 1);
			var vastAd:VASTAd = document.ads[0];
			assertTrue(vastAd != null);
			assertTrue(vastAd.id == "mywrapperad");
			assertTrue(vastAd.inlineAd == null);
			assertTrue(vastAd.wrapperAd != null);
			
			var wrapperAd:VASTWrapperAd = vastAd.wrapperAd;
			assertTrue(wrapperAd.vastAdTagURL == "http://www.secondaryadserver.com/ad/tag/parameters?time=1234567");
			assertTrue(wrapperAd.adSystem == "MyAdSystem");
			assertTrue(wrapperAd.errorURL == "http://www.primarysite.com/tracker?noPlay=true&impressionTracked=false");
			
			assertTrue(wrapperAd.impressions != null);
			assertTrue(wrapperAd.impressions.length == 1);
			var impression:VASTUrl = wrapperAd.impressions[0];
			assertTrue(impression.id == "myadsever");
			assertTrue(impression.url == "http://www.primarysite.com/tracker?imp");
			
			assertTrue(wrapperAd.trackingEvents != null);
			assertTrue(wrapperAd.trackingEvents.length == 8);
			
			var trackingEvent:VASTTrackingEvent = wrapperAd.trackingEvents[0];
			assertTrue(trackingEvent.type == VASTTrackingEventType.MIDPOINT);
			assertTrue(trackingEvent.urls.length == 1);
			var trackingURL:VASTUrl = trackingEvent.urls[0];
			assertTrue(trackingURL.id == "myadsever");
			assertTrue(trackingURL.url == "http://www.primarysite.com/tracker?mid");
			
			trackingEvent = wrapperAd.trackingEvents[1];
			assertTrue(trackingEvent.type == VASTTrackingEventType.FIRST_QUARTILE);
			assertTrue(trackingEvent.urls.length == 1);
			trackingURL = trackingEvent.urls[0];
			assertTrue(trackingURL.id == "myadsever");
			assertTrue(trackingURL.url == "http://www.primarysite.com/tracker?fqtl");

			trackingEvent = wrapperAd.trackingEvents[2];
			assertTrue(trackingEvent.type == VASTTrackingEventType.THIRD_QUARTILE);
			assertTrue(trackingEvent.urls.length == 1);
			trackingURL = trackingEvent.urls[0];
			assertTrue(trackingURL.id == "myadsever");
			assertTrue(trackingURL.url == "http://www.primarysite.com/tracker?tqtl");

			trackingEvent = wrapperAd.trackingEvents[3];
			assertTrue(trackingEvent.type == VASTTrackingEventType.COMPLETE);
			assertTrue(trackingEvent.urls.length == 1);
			trackingURL = trackingEvent.urls[0];
			assertTrue(trackingURL.id == "myadsever");
			assertTrue(trackingURL.url == "http://www.primarysite.com/tracker?comp");

			trackingEvent = wrapperAd.trackingEvents[4];
			assertTrue(trackingEvent.type == VASTTrackingEventType.MUTE);
			assertTrue(trackingEvent.urls.length == 1);
			trackingURL = trackingEvent.urls[0];
			assertTrue(trackingURL.id == "myadsever");
			assertTrue(trackingURL.url == "http://www.primarysite.com/tracker?mute");

			trackingEvent = wrapperAd.trackingEvents[5];
			assertTrue(trackingEvent.type == VASTTrackingEventType.PAUSE);
			assertTrue(trackingEvent.urls.length == 1);
			trackingURL = trackingEvent.urls[0];
			assertTrue(trackingURL.id == "myadsever");
			assertTrue(trackingURL.url == "http://www.primarysite.com/tracker?pause");

			trackingEvent = wrapperAd.trackingEvents[6];
			assertTrue(trackingEvent.type == VASTTrackingEventType.REPLAY);
			assertTrue(trackingEvent.urls.length == 1);
			trackingURL = trackingEvent.urls[0];
			assertTrue(trackingURL.id == "myadsever");
			assertTrue(trackingURL.url == "http://www.primarysite.com/tracker?replay");

			trackingEvent = wrapperAd.trackingEvents[7];
			assertTrue(trackingEvent.type == VASTTrackingEventType.FULLSCREEN);
			assertTrue(trackingEvent.urls.length == 1);
			trackingURL = trackingEvent.urls[0];
			assertTrue(trackingURL.id == "myadsever");
			assertTrue(trackingURL.url == "http://www.primarysite.com/tracker?full");
			
			assertTrue(wrapperAd.videoClick != null);
			var videoClick:VASTVideoClick = wrapperAd.videoClick;
			
			assertTrue(videoClick.clickThrough != null);
			assertTrue(videoClick.clickThrough.id == "myadsever");
			assertTrue(videoClick.clickThrough.url == "http://www.primarysite.com/tracker?clickthrough");
			
			assertTrue(videoClick.clickTrackings != null);
			assertTrue(videoClick.clickTrackings.length == 2);
			var clickTracking:VASTUrl = videoClick.clickTrackings[0];
			assertTrue(clickTracking.id == "myadsever");
			assertTrue(clickTracking.url == "http://www.primarysite.com/tracker?click1");
			clickTracking = videoClick.clickTrackings[1];
			assertTrue(clickTracking.id == "myadsever");
			assertTrue(clickTracking.url == "http://www.primarysite.com/tracker?click2");
			
			assertTrue(videoClick.customClicks != null);
			assertTrue(videoClick.customClicks.length == 2);
			var customClick:VASTUrl = videoClick.customClicks[0];
			assertTrue(customClick.id == "myadsever");
			assertTrue(customClick.url == "http://www.primarysite.com/tracker?customclick1");
			customClick = videoClick.customClicks[1];
			assertTrue(customClick.id == "myadsever");
			assertTrue(customClick.url == "http://www.primarysite.com/tracker?customclick2");
			
			assertTrue(wrapperAd.companionImpressions != null);
			assertTrue(wrapperAd.companionImpressions.length == 2);
			var companionImpression:VASTUrl = wrapperAd.companionImpressions[0];
			assertTrue(companionImpression.id == "myadsever");
			assertTrue(companionImpression.url == "http://www.primarysite.com/tracker?comp1");
			companionImpression = wrapperAd.companionImpressions[1];
			assertTrue(companionImpression.id == "myadsever");
			assertTrue(companionImpression.url == "http://www.primarysite.com/tracker?comp2");
			assertTrue(wrapperAd.companionAdTag == null);

			assertTrue(wrapperAd.nonLinearImpressions != null);
			assertTrue(wrapperAd.nonLinearImpressions.length == 2);
			var nonLinearImpression:VASTUrl = wrapperAd.nonLinearImpressions[0];
			assertTrue(nonLinearImpression.id == "myadsever");
			assertTrue(nonLinearImpression.url == "http://www.primarysite.com/tracker?nl1");
			nonLinearImpression = wrapperAd.nonLinearImpressions[1];
			assertTrue(nonLinearImpression.id == "myadsever");
			assertTrue(nonLinearImpression.url == "http://www.primarysite.com/tracker?nl2");
			assertTrue(wrapperAd.nonLinearAdTag == null);
			
			assertTrue(wrapperAd.extensions != null);
			assertTrue(wrapperAd.extensions.length == 1);
			
			var extension:XML = wrapperAd.extensions[0];
			var expectedXML:XML =
				<Extension type="adServer" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
					<TemplateVersion>3.002</TemplateVersion>
					<AdServingData>
						<DeliveryData>
							<GeoData><![CDATA[ct=US&st=VA&ac=703&zp=20151&bw=4&dma=13&city=15719]]></GeoData>
							<MyAdId>43534850</MyAdId>
						</DeliveryData>
					</AdServingData>
				</Extension>;
			assertTrue(extension.toXMLString() == expectedXML.toXMLString());
		}
		
		public function testParseWrapperAdWithCompanionAndNonLinearAdTags():void
		{
			var document:VASTDocument = parser.parse(WRAPPER_VAST_DOCUMENT_WITH_AD_TAGS);
			assertTrue(document != null);
			assertTrue(document.ads.length == 1);
			var vastAd:VASTAd = document.ads[0];
			assertTrue(vastAd != null);
			assertTrue(vastAd.id == "mywrapperad");
			assertTrue(vastAd.inlineAd == null);
			assertTrue(vastAd.wrapperAd != null);
			
			var wrapperAd:VASTWrapperAd = vastAd.wrapperAd;

			assertTrue(wrapperAd.companionImpressions != null);
			assertTrue(wrapperAd.companionImpressions.length == 0);
			assertTrue(wrapperAd.companionAdTag != null);
			assertTrue(wrapperAd.companionAdTag.id == "myadsever");
			assertTrue(wrapperAd.companionAdTag.url == "http://www.primarysite.com/tracker?comp");

			assertTrue(wrapperAd.nonLinearImpressions != null);
			assertTrue(wrapperAd.nonLinearImpressions.length == 0);
			assertTrue(wrapperAd.nonLinearAdTag != null);
			assertTrue(wrapperAd.nonLinearAdTag.id == "myadsever");
			assertTrue(wrapperAd.nonLinearAdTag.url == "http://www.primarysite.com/tracker?nl");
		}

		public function testParseWrapperAdWithTooManyCompanionAndNonLinearAdTagURLs():void
		{
			var document:VASTDocument = parser.parse(WRAPPER_VAST_DOCUMENT_WITH_TOO_MANY_AD_TAG_URLS);
			assertTrue(document != null);
			assertTrue(document.ads.length == 1);
			var vastAd:VASTAd = document.ads[0];
			assertTrue(vastAd != null);
			assertTrue(vastAd.id == "mywrapperad");
			assertTrue(vastAd.inlineAd == null);
			assertTrue(vastAd.wrapperAd != null);
			
			var wrapperAd:VASTWrapperAd = vastAd.wrapperAd;

			assertTrue(wrapperAd.companionImpressions != null);
			assertTrue(wrapperAd.companionImpressions.length == 0);
			assertTrue(wrapperAd.companionAdTag != null);
			assertTrue(wrapperAd.companionAdTag.id == "myadsever");
			assertTrue(wrapperAd.companionAdTag.url == "http://www.primarysite.com/tracker?comp1");

			assertTrue(wrapperAd.nonLinearImpressions != null);
			assertTrue(wrapperAd.nonLinearImpressions.length == 0);
			assertTrue(wrapperAd.nonLinearAdTag != null);
			assertTrue(wrapperAd.nonLinearAdTag.id == "myadsever");
			assertTrue(wrapperAd.nonLinearAdTag.url == "http://www.primarysite.com/tracker?nl1");
		}

		private var parser:VASTParser;
		
		private static const INLINE_VAST_DOCUMENT:XML =
			<VideoAdServingTemplate xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="vast.xsd">
				<Ad id="myinlinead">
					<InLine>
						<AdSystem>DART</AdSystem>
						<AdTitle>Spiderman 3 Trailer</AdTitle>
						<Description>Spiderman video trailer</Description>
						<Survey>
							<URL><![CDATA[ http://www.dynamiclogic.com/tracker?campaignId=234&site=yahoo]]></URL>
						</Survey>
						<Error>
							<URL><![CDATA[http://www.primarysite.com/tracker?noPlay=true&impressionTracked=false]]></URL>
						</Error>
						<Impression>
							<URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?imp]]></URL>
							<URL id="anotheradsever"><![CDATA[http://www.thirdparty.com/tracker?imp]]></URL>
						</Impression>
						<TrackingEvents>
							<Tracking event="start">
								<URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?start]]></URL>
							</Tracking>
							<Tracking event="midpoint">
								<URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?mid]]></URL>
								<URL id="anotheradsever"><![CDATA[http://www.thirdparty.com/tracker?mid]]></URL>
							</Tracking>
							<Tracking event="firstQuartile">
								<URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?fqtl]]></URL>
								<URL id="anotheradsever"><![CDATA[http://www.thirdparty.com/tracker?fqtl]]></URL>
							</Tracking>
							<Tracking event="thirdQuartile">
								<URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?tqtl]]></URL>
								<URL id="anotheradsever"><![CDATA[http://www.thirdparty.com/tracker?tqtl]]></URL>
							</Tracking>
							<Tracking event="complete">
								<URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?comp]]></URL>
								<URL id="anotheradsever"><![CDATA[http://www.thirdparty.com/tracker?comp]]></URL>
							</Tracking>
							<Tracking event="mute">
								<URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?mute]]></URL>
							</Tracking>
							<Tracking event="pause">
								<URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?pause]]></URL>
							</Tracking>
							<Tracking event="replay">
								<URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?replay]]></URL>
							</Tracking>
							<Tracking event="fullscreen">
								<URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?full]]></URL>
							</Tracking>
							<Tracking event="stop">
								<URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?stop]]></URL>
							</Tracking>
						</TrackingEvents>
						<Video>
							<Duration>00:00:15</Duration>
							<AdID>AdID</AdID>
							<VideoClicks>
								<ClickThrough>
									<URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?click]]></URL>
								</ClickThrough>
								<ClickTracking>
									<URL id="anotheradsever"><![CDATA[http://www.thirdparty.com/tracker?click]]></URL>
									<URL id="athirdadsever"><![CDATA[http://www.thirdparty.com/tracker?click]]></URL>
								</ClickTracking>
								<CustomClick>
									<URL id="redclick"><![CDATA[http://www.thirdparty.com/tracker?click]]></URL>
									<URL id="blueclick"><![CDATA[http://www.thirdparty.com/tracker?click]]></URL>
								</CustomClick>
							</VideoClicks>
							<MediaFiles>
								<MediaFile delivery="streaming" bitrate="250" width="200" height="200" type="video/x-flv">
									<URL><![CDATA[rtmp://streamingserver/streamingpath/medium/filename.flv]]></URL>
								</MediaFile>
								<MediaFile delivery="streaming" bitrate="75" width="200" height="200" type="video/x-flv">
									<URL><![CDATA[rtmp://streamingserver/streamingpath/low/filename.flv]]></URL>
								</MediaFile>
								<MediaFile delivery="progressive" bitrate="400" width="200" height="200" type="video/x-flv">
									<URL><![CDATA[http://progressive.hostlocation.com//high/filename.flv]]></URL>
								</MediaFile>
								<MediaFile delivery="progressive" bitrate="200" width="200" height="200" type="video/x-flv">
									<URL><![CDATA[http://progressive.hostlocation.com/progressivepath/medium/filename.flv]]></URL>
								</MediaFile>
								<MediaFile delivery="progressive" bitrate="75" width="200" height="200" type="video/x-flv">
									<URL><![CDATA[http://progressive.hostlocation.com/progressivepath/low/filename.flv]]></URL>
								</MediaFile>
								<MediaFile delivery="streaming" bitrate="400" width="200" height="200" type="video/x-ms-wmv">
									<URL><![CDATA[mms://streaming.hostlocaltion.com/ondemand/streamingpath/high/filename.wmv]]></URL>
					            </MediaFile>
					            <MediaFile delivery="streaming" bitrate="200" width="200" height="200" type="video/x-ms-wmv">
					                <URL><![CDATA[mms://streaming.hostlocaltion.com/ondemand/streamingpath/medium/filename.wmv]]></URL>
					            </MediaFile>
					            <MediaFile delivery="streaming" bitrate="75" width="200" height="200" type="video/x-ms-wmv">
					                <URL><![CDATA[mms://streaming.hostlocaltion.com/ondemand/streamingpath/low/filename.wmv]]></URL>
					            </MediaFile>
					            <MediaFile delivery="progressive" bitrate="400" width="200" height="200" type="video/x-ms-wmv">
					                <URL><![CDATA[http://progressive.hostlocation.com//high/filename.wmv]]></URL>
								</MediaFile>
								<MediaFile delivery="progressive" bitrate="200" width="200" height="200" type="video/x-ms-wmv">
									<URL><![CDATA[http://progressive.hostlocation.com/progressivepath/medium/filename.wmv]]></URL>
								</MediaFile>
								<MediaFile delivery="progressive" bitrate="75" width="200" height="200" type="video/x-ms-wmv">
									<URL><![CDATA[http://progressive.hostlocation.com/progressivepath/low/filename.wmv]]></URL>
								</MediaFile>
								<MediaFile delivery="streaming" bitrate="200" width="200" height="200" type="video/x-ra">
									<URL><![CDATA[rtsp://streaming.hostlocaltion.com/ondemand/streamingpath/medium/filename.ra]]></URL>
					            </MediaFile>
					            <MediaFile delivery="streaming" bitrate="75" width="200" height="200" type="video/x-ra">
					                <URL><![CDATA[rtsp://streaming.hostlocaltion.com/ondemand/streamingpath/low/filename.ra]]></URL>
					            </MediaFile>
					            <MediaFile delivery="progressive" bitrate="400" width="200" height="200" type="video/x-ra">
			                		<URL><![CDATA[http://progressive.hostlocation.com//high/filename.ra]]></URL>
								</MediaFile>
								<MediaFile delivery="progressive" bitrate="200" width="200" height="200" type="video/x-ra">
									<URL><![CDATA[http://progressive.hostlocation.com/progressivepath/medium/filename.ra]]></URL>
								</MediaFile>
								<MediaFile delivery="progressive" bitrate="75" width="200" height="200" type="video/x-ra">
									<URL><![CDATA[http://progressive.hostlocation.com/progressivepath/low/filename.ra]]></URL>
								</MediaFile>
							</MediaFiles>
						</Video>
						<CompanionAds>
							<Companion id="rich media banner" width="468" height="60" resourceType="iframe" creativeType="any">
								<URL><![CDATA[http://ad.server.com/adi/etc.html]]></URL>
							</Companion>
							<Companion id="banner1" width="728" height="90" resourceType="script" creativeType="any">
								<URL><![CDATA[http://ad.server.com/adj/etc.js]]></URL>
							</Companion>
							<Companion id="banner2" width="468" height="60" resourceType="static" creativeType="JPEG">
								<URL><![CDATA[http://media.doubleclick.net/foo.jpg]]></URL>
								<CompanionClickThrough>
									<URL><![CDATA[http://www.primarysite.com/tracker?click]]></URL>
								</CompanionClickThrough>
							</Companion>
							<Companion id="banner3" width="468" height="60" resourceType="static" creativeType="JPEG" expandedWidth="728" expandedHeight="90">
								<Code>insert code here</Code>
								<CompanionClickThrough>
									<URL><![CDATA[http://www.primarysite.com/tracker?click]]></URL>
								</CompanionClickThrough>
								<AltText>some alt text</AltText>
								<AdParameters apiFramework="FlashVars">param=value</AdParameters>
							</Companion>
						</CompanionAds>
						<NonLinearAds>
							<NonLinear id="overlay" width="150" height="60" resourceType="static" creativeType="SWF" apiFramework="IAB">
								<URL><![CDATA[http://ad.server.com/adx/etc.xml]]></URL>
								<NonLinearClickThrough>
									<URL><![CDATA[http://www.thirdparty.com/tracker?click]]></URL>
								</NonLinearClickThrough>
							</NonLinear>
							<NonLinear id="bumper" width="250" height="300" resourceType="static" creativeType="JPEG">
								<URL><![CDATA[http://ad.doubleclick.net/adx/etc.jpg]]></URL>
								<NonLinearClickThrough>
									<URL><![CDATA[http://www.thirdparty.com/tracker?click]]></URL>
								</NonLinearClickThrough>
							</NonLinear>
							<NonLinear id="overlay2" width="350" height="100" resourceType="other" creativeType="JPEG" expandedWidth="728" expandedHeight="90" scalable="true" maintainAspectRatio="true">
								<Code>insert code here</Code>
								<NonLinearClickThrough>
									<URL><![CDATA[http://www.thirdparty.com/tracker?click2]]></URL>
								</NonLinearClickThrough>
								<AdParameters apiFramework="FlashVars">param=value</AdParameters>
							</NonLinear>
						</NonLinearAds>
						<Extensions>
							<Extension type="adServer">
								<TemplateVersion>3.002</TemplateVersion>
								<AdServingData>
									<DeliveryData>
										<GeoData><![CDATA[ct=US&st=VA&ac=703&zp=20151&bw=4&dma=13&city=15719]]></GeoData>
										<MyAdId>43534850</MyAdId>
									</DeliveryData>
								</AdServingData>
							</Extension>
						</Extensions>
					</InLine>
				</Ad>
			</VideoAdServingTemplate>;
			
		private static const WRAPPER_VAST_DOCUMENT:XML =
			<VideoAdServingTemplate xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="vast.xsd">
			  <Ad id="mywrapperad">
			   <Wrapper>
			    <AdSystem>MyAdSystem</AdSystem>
			    <VASTAdTagURL>
			        <URL><![CDATA[http://www.secondaryadserver.com/ad/tag/parameters?time=1234567]]></URL>
			    </VASTAdTagURL>
			    <Error>
			        <URL><![CDATA[http://www.primarysite.com/tracker?noPlay=true&impressionTracked=false]]></URL>
			    </Error>
			    <Impression>
			            <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?imp]]></URL>
			    </Impression>
			    <TrackingEvents>
			        <Tracking event="midpoint">
			            <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?mid]]></URL>
			        </Tracking>
			        <Tracking event="firstQuartile">
			            <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?fqtl]]></URL>
			        </Tracking>
			        <Tracking event="thirdQuartile">
			            <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?tqtl]]></URL>
			        </Tracking>
			        <Tracking event="complete">
			            <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?comp]]></URL>
			        </Tracking>
			        <Tracking event="mute">
			            <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?mute]]></URL>
			        </Tracking>
			        <Tracking event="pause">
			            <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?pause]]></URL>
			        </Tracking>
			        <Tracking event="replay">
			            <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?replay]]></URL>
			        </Tracking>
			        <Tracking event="fullscreen">
			            <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?full]]></URL>
			        </Tracking>
			     </TrackingEvents>
				 <CompanionAds>
					<CompanionImpression>
						 <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?comp1]]></URL>
						 <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?comp2]]></URL>
					</CompanionImpression>
					<!-- CompanionAdTag>
						 <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?adtag]]></URL>
					</CompanionImpression>
					<CompanionAdTag>
						 <Code id="myadsever">insert code here</URL>
					</CompanionImpression -->
				 </CompanionAds>
				 <NonLinearAds>
					<NonLinearImpression>
						 <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?nl1]]></URL>
						 <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?nl2]]></URL>
					</NonLinearImpression>
				 </NonLinearAds>
		         <VideoClicks>
		            <ClickTracking>
						 <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?click1]]></URL>
						 <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?click2]]></URL>
		            </ClickTracking>
		            <ClickThrough>
						 <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?clickthrough]]></URL>
		            </ClickThrough>
		            <CustomClick>
						 <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?customclick1]]></URL>
						 <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?customclick2]]></URL>
		            </CustomClick>
		         </VideoClicks>
				 <Extensions>
					<Extension type="adServer">
						<TemplateVersion>3.002</TemplateVersion>
						<AdServingData>
							<DeliveryData>
								<GeoData><![CDATA[ct=US&st=VA&ac=703&zp=20151&bw=4&dma=13&city=15719]]></GeoData>
								<MyAdId>43534850</MyAdId>
							</DeliveryData>
						</AdServingData>
					</Extension>
				 </Extensions>
			   </Wrapper>
			  </Ad>
			</VideoAdServingTemplate>;
			
		private static const WRAPPER_VAST_DOCUMENT_WITH_AD_TAGS:XML =
			<VideoAdServingTemplate xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="vast.xsd">
			  <Ad id="mywrapperad">
			   <Wrapper>
			    <AdSystem>MyAdSystem</AdSystem>
			    <VASTAdTagURL>
			        <URL><![CDATA[http://www.secondaryadserver.com/ad/tag/parameters?time=1234567]]></URL>
			    </VASTAdTagURL>
			    <Impression>
			        <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?imp]]></URL>
			    </Impression>
				<CompanionAds>
					<CompanionAdTag>
						 <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?comp]]></URL>
					</CompanionAdTag>
				</CompanionAds>
				<NonLinearAds>
					<NonLinearAdTag>
						 <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?nl]]></URL>
					</NonLinearAdTag>
				</NonLinearAds>
			   </Wrapper>
			  </Ad>
			</VideoAdServingTemplate>;

		private static const WRAPPER_VAST_DOCUMENT_WITH_TOO_MANY_AD_TAG_URLS:XML =
			<VideoAdServingTemplate xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="vast.xsd">
			  <Ad id="mywrapperad">
			   <Wrapper>
			    <AdSystem>MyAdSystem</AdSystem>
			    <VASTAdTagURL>
			        <URL><![CDATA[http://www.secondaryadserver.com/ad/tag/parameters?time=1234567]]></URL>
			    </VASTAdTagURL>
			    <Impression>
			        <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?imp]]></URL>
			    </Impression>
				<CompanionAds>
					<CompanionAdTag>
						 <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?comp1]]></URL>
						 <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?comp2]]></URL>
					</CompanionAdTag>
				</CompanionAds>
				<NonLinearAds>
					<NonLinearAdTag>
						 <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?nl1]]></URL>
						 <URL id="myadsever"><![CDATA[http://www.primarysite.com/tracker?nl2]]></URL>
					</NonLinearAdTag>
				</NonLinearAds>
			   </Wrapper>
			  </Ad>
			</VideoAdServingTemplate>;
	}
}