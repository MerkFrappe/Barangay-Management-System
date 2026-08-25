var url = "https://api.gumroad.com/v2/licenses/verify";
var currentTab;

$(document).ready(function() {
    var query = {
        active: true,
        currentWindow: true
    };

    chrome.tabs.query(query, function(tabs) {
        currentTab = tabs[0];
        if (currentTab.url.match(/facebook.com\/messages|facebook.com\/latest\/inbox/i)) {
            $("#aa").show();
        } else {
            $("#bb").show();
        }
    });
});

var app = angular.module("myapp", []);
var headers = {
    "content-type": "application/x-www-form-urlencoded"
};

app.controller("ctrl", function($scope, $http, $q, $filter) {

    var s = $scope;

    if (!localStorage.trial) {
        s.license = true;
        s.trialStarted = true;
    }

    s.verify_license = function(key) {
        if (key) {
            s.licensebb = true;
            $scope.manageLink = "";

            $scope.error = false;
            $http({
                method: "post",
                url: url,
                data: $.param({
                    license_key: key,
                    product_id: "DtzbbzVet_LdAEQfrLk3AQ=="
                }),
                headers: headers,
            }).then(function(r) {

                $scope.licensebb = false;

                if (r.data.success) {
                    $scope.manageLink = "https://app.gumroad.com/subscriptions/" + r.data.purchase.subscription_id + "/manage";
                }

                if (r.data.success && !r.data.purchase.subscription_cancelled_at && !r.data.purchase.subscription_failed_at) {
                    $scope.license = true;
                    chrome.storage.local.set({
                        license_key: key
                    });
                } else {
                    $scope.error = true;
                }
            }, function() {
                $scope.licensebb = false;
                $scope.error = true;
            })
        }
    }

    chrome.storage.local.get("license_key", function(l) {
        var k = l.license_key;
        if (k) {
            $scope.$apply(function() {
                $scope.license = true;
                $scope.manageLink = "";

                $http({
                    method: "post",
                    url: url,
                    data: $.param({
                        license_key: k,
                        product_id: "DtzbbzVet_LdAEQfrLk3AQ=="
                    }),
                    headers: headers,
                }).then(function(r) {
                    if (r.data.success) {
                        $scope.manageLink = "https://app.gumroad.com/subscriptions/" + r.data.purchase.subscription_id + "/manage";
                    }
                    if (r.data.success && !r.data.purchase.subscription_cancelled_at && !r.data.purchase.subscription_failed_at) {

                    } else {
                        chrome.storage.local.set({
                            license_key: ""
                        });
                        $scope.license = false;
                    }
                }, function(re) {
                    if (typeof re.data.success != 'undefined' && !re.data.success) {
                        chrome.storage.local.set({
                            license_key: ""
                        })
                        $scope.license = false;
                    }
                })

            })
        }
    })

    s.delete = function() {
        var file = "js/fb.js";
        if (currentTab.url.match(/facebook\.com\/latest\/inbox/i)) {
            file = "js/fbpage.js";
        }

        chrome.scripting.executeScript({
            target: {
                tabId: currentTab.id
            },
            files: ["js/jquery.min.js", file]
        }, function() {
            window.close();
            localStorage.trial = "false";
        });
    }

    s.archive = function() {
        chrome.scripting.executeScript({
            target: {
                tabId: currentTab.id
            },
            files: ["js/jquery.min.js", "js/archive.js"]
        }, function() {
            window.close();
            localStorage.trial = "false";
        });
    }

    s.unArchive = function() {
        chrome.scripting.executeScript({
            target: {
                tabId: currentTab.id
            },
            files: ["js/jquery.min.js", "js/unarchive.js"]
        }, function() {
            window.close();
            localStorage.trial = "false";
        });
    }
});
